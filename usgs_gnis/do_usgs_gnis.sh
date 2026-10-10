#!/usr/bin/env bash

# Download the GNIS national GeoPackage, load all its layers and tables into
# PostGIS, then build convenience views and report key-link quality checks.
set -Eeuo pipefail

# Supply connection settings through the environment. Authentication can use
# .pgpass or the standard PGPASSWORD/PGPASSFILE environment variables.
DBHOST=""
DBPORT="5432"
DBUSER=""
DBNAME=""
DBSCHEMA=""
export PGPASSWORD=""

WGET="wget"
UNZIP="unzip"
PSQL="psql"
OGR2OGR="ogr2ogr"
OGRINFO="ogrinfo"

SOURCE_URL="https://prd-tnm.s3.amazonaws.com/StagedProducts/GeographicNames/FullModel/Gazetteer_National_GPKG.zip"
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATADIR="${BASEDIR}/national_gpkg_data"
DOWNLOAD_DIR="${DATADIR}/downloads"
EXTRACT_DIR="${DATADIR}/extracted"
VIEWS_SQL="${BASEDIR}/gnis_views.sql"

# Exit function
die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

# Check if our tools are installed on the system
for tool in "$WGET" "$UNZIP" "$PSQL" "$OGR2OGR" "$OGRINFO"; do
    command -v "$tool" >/dev/null 2>&1 || die "Required command not found on PATH: $tool"
done

# Check if our required variables are defined
[[ -n "$DBHOST" ]] || die "Set DBHOST near the top of this script."
[[ -n "$DBPORT" ]] || die "Set DBPORT near the top of this script."
[[ -n "$DBUSER" ]] || die "Set DBUSER near the top of this script."
[[ -n "$DBUSER" ]] || die "Set DBUSER near the top of this script."
[[ -n "$DBNAME" ]] || die "Set DBNAME near the top of this script."
[[ -n "$DBSCHEMA" ]] || die "Set DBSCHEMA near the top of this script."
[[ -n "$PGPASSWORD" ]] || die "Set PGPASSWORD near the top of this script."
[[ -n "$SOURCE_URL" ]] || die "Set SOURCE_URL near the top of this script."
[[ -n "$BASEDIR" ]] || die "Set BASEDIR near the top of this script."
[[ -n "$DATADIR" ]] || die "Set DATADIR near the top of this script."
[[ -n "$DOWNLOAD_DIR" ]] || die "Set DOWNLOAD_DIR near the top of this script."
[[ -n "$EXTRACT_DIR" ]] || die "Set EXTRACT_DIR near the top of this script."
[[ -n "$VIEWS_SQL" ]] || die "Set VIEWS_SQL near the top of this script."


# Create our download directories
mkdir -p -- "$DOWNLOAD_DIR" "$EXTRACT_DIR"

# Set our psql arguments
PSQL_ARGS=(
    --port="$DBPORT"
    --username="$DBUSER"
    --dbname="$DBNAME"
    --set=ON_ERROR_STOP=1
    --quiet
)
[[ -n "$DBHOST" ]] && PSQL_ARGS+=(--host="$DBHOST")

PG_CONNECTION="PG:dbname=${DBNAME} port=${DBPORT} user=${DBUSER}"
[[ -n "$DBHOST" ]] && PG_CONNECTION+=" host=${DBHOST}"

archive_name="${SOURCE_URL##*/}"
archive_path="${DOWNLOAD_DIR}/${archive_name}"

# Check if we need to download or just use a pre-existing download
if [[ -s "$archive_path" ]] && "$UNZIP" -tq "$archive_path" >/dev/null 2>&1; then
    printf 'Using existing archive %s\n' "$archive_name"
else
    rm -f -- "$archive_path"
    printf 'Downloading %s\n' "$archive_name"
    "$WGET" --continue --directory-prefix="$DOWNLOAD_DIR" "$SOURCE_URL" ||
        die "Download failed: $SOURCE_URL"
    "$UNZIP" -tq "$archive_path" >/dev/null ||
        die "Downloaded file is not a valid ZIP archive: $archive_path"
fi

"$UNZIP" -oq "$archive_path" -d "$EXTRACT_DIR" ||
    die "Unable to extract $archive_path"

mapfile -d '' -t geopackages < <(
    find "$EXTRACT_DIR" -type f -iname 'Gazetteer_National_GPKG.gpkg' -print0 | sort -z
)
((${#geopackages[@]} == 1)) ||
    die "Expected one Gazetteer_National_GPKG.gpkg in $EXTRACT_DIR; found ${#geopackages[@]}"
geopackage="${geopackages[0]}"

printf 'Preparing schema %s in database %s\n' "$DBSCHEMA" "$DBNAME"
"$PSQL" "${PSQL_ARGS[@]}" \
    --command="CREATE SCHEMA IF NOT EXISTS \"${DBSCHEMA}\";"

# The loader replaces the imported tables. Drop only the views managed by the
# companion SQL file so PostgreSQL permits those table replacements.
"$PSQL" "${PSQL_ARGS[@]}" --command="
    DROP VIEW IF EXISTS
        \"${DBSCHEMA}\".v_feature_detail,
        \"${DBSCHEMA}\".v_feature_names,
        \"${DBSCHEMA}\".v_feature_designations,
        \"${DBSCHEMA}\".v_bgn_decisions,
        \"${DBSCHEMA}\".v_feature_counties,
        \"${DBSCHEMA}\".v_feature_states,
        \"${DBSCHEMA}\".v_feature_quadrangles,
        \"${DBSCHEMA}\".v_feature_federal_codes;
"

layer_listing="$("$OGRINFO" -ro -q "$geopackage")" ||
    die "Could not list layers in $geopackage"
source_layers=()
source_geometry_types=()
while IFS= read -r layer_info; do
    if [[ "$layer_info" =~ ^[[:space:]]*[0-9]+:[[:space:]](.+)[[:space:]]\(([^()]*)\)[[:space:]]*$ ]]; then
        source_layers+=("${BASH_REMATCH[1]}")
        source_geometry_types+=("${BASH_REMATCH[2]}")
    fi
done <<< "$layer_listing"
((${#source_layers[@]} > 0)) || die "No layers or tables found in $geopackage"

# Normalize our table names by changing spaces to _
normalize_table_name() {
    local name="${1,,}"
    name="${name//[^a-z0-9_]/_}"
    [[ "$name" =~ ^[0-9] ]] && name="gnis_${name}"
    name="${name:0:63}"
    printf '%s' "$name"
}

# Return a SQL string literal, escaping embedded single quotes.
sql_literal() {
    local value="${1//\'/\'\'}"
    printf "'%s'" "$value"
}

# Quote one PostgreSQL identifier, escaping embedded double quotes.
sql_identifier() {
    local value="${1//\"/\"\"}"
    printf '"%s"' "$value"
}

maintain_table() {
    local table_name="$1"
    local schema_sql table_sql geometry_column geometry_sql gist_index
    schema_sql="$(sql_identifier "$DBSCHEMA")"
    table_sql="$(sql_identifier "$table_name")"

    printf 'Vacuum analyze %s.%s\n' "$DBSCHEMA" "$table_name"
    "$PSQL" "${PSQL_ARGS[@]}" \
        --command="VACUUM ANALYZE ${schema_sql}.${table_sql};" ||
        die "VACUUM ANALYZE failed for ${DBSCHEMA}.${table_name}"

    geometry_column="$("$PSQL" "${PSQL_ARGS[@]}" --tuples-only --no-align \
        --command="SELECT f_geometry_column FROM public.geometry_columns WHERE f_table_schema = $(sql_literal "$DBSCHEMA") AND f_table_name = $(sql_literal "$table_name") ORDER BY f_geometry_column LIMIT 1;")" ||
        die "Could not inspect geometry columns for ${DBSCHEMA}.${table_name}"
    geometry_column="${geometry_column//$'\n'/}"

    if [[ -z "$geometry_column" ]]; then
        printf 'No geometry column found on %s.%s; skipping CLUSTER\n' \
            "$DBSCHEMA" "$table_name"
    else
        geometry_sql="$(sql_literal "$geometry_column")"
        gist_index="$("$PSQL" "${PSQL_ARGS[@]}" --tuples-only --no-align \
            --command="SELECT index_class.relname FROM pg_class AS table_class JOIN pg_namespace AS table_ns ON table_ns.oid = table_class.relnamespace JOIN pg_index AS index_info ON index_info.indrelid = table_class.oid AND index_info.indisvalid AND index_info.indisready JOIN pg_class AS index_class ON index_class.oid = index_info.indexrelid JOIN pg_am AS access_method ON access_method.oid = index_class.relam AND access_method.amname = 'gist' JOIN pg_attribute AS geom_attribute ON geom_attribute.attrelid = table_class.oid AND geom_attribute.attname = ${geometry_sql} AND NOT geom_attribute.attisdropped WHERE table_ns.nspname = $(sql_literal "$DBSCHEMA") AND table_class.relname = $(sql_literal "$table_name") AND geom_attribute.attnum = ANY(index_info.indkey) ORDER BY index_class.relname LIMIT 1;")" ||
            die "Could not inspect GiST indexes for ${DBSCHEMA}.${table_name}"
        gist_index="${gist_index//$'\n'/}"

        if [[ -z "$gist_index" ]]; then
            printf 'No valid GiST index found on %s.%s.%s; skipping CLUSTER\n' \
                "$DBSCHEMA" "$table_name" "$geometry_column"
        else
            printf 'Cluster %s.%s using %s\n' \
                "$DBSCHEMA" "$table_name" "$gist_index"
            "$PSQL" "${PSQL_ARGS[@]}" \
                --command="CLUSTER ${schema_sql}.${table_sql} USING $(sql_identifier "$gist_index");" ||
                die "CLUSTER failed for ${DBSCHEMA}.${table_name}"
        fi
    fi

    printf 'Analyze %s.%s\n' "$DBSCHEMA" "$table_name"
    "$PSQL" "${PSQL_ARGS[@]}" \
        --command="ANALYZE ${schema_sql}.${table_sql};" ||
        die "ANALYZE failed for ${DBSCHEMA}.${table_name}"
}

declare -A table_sources=()
layer_count=0
for i in "${!source_layers[@]}"; do
    source_layer="${source_layers[$i]}"
    source_geometry_type="${source_geometry_types[$i]}"
    table_name="$(normalize_table_name "$source_layer")"

    if [[ -n "${table_sources[$table_name]+present}" ]]; then
        die "Layer name collision: ${table_sources[$table_name]} and ${source_layer} both map to ${DBSCHEMA}.${table_name}"
    fi
    table_sources[$table_name]="$source_layer"

    ogr2ogr_options=(
        -nln "$table_name"
        -overwrite
        -lco "SCHEMA=${DBSCHEMA}"
    )
    if [[ "$source_geometry_type" != "None" ]]; then
        if [[ "$source_geometry_type" == *Multi* ]]; then
            ogr2ogr_options+=(-nlt PROMOTE_TO_MULTI)
        fi
        ogr2ogr_options+=(
            -lco GEOMETRY_NAME=geom
            -lco SPATIAL_INDEX=GIST
        )
    fi

    printf 'Loading %s -> %s.%s (%s)\n' \
        "$source_layer" "$DBSCHEMA" "$table_name" "$source_geometry_type"
    "$OGR2OGR" --config OGR2OGR_USE_ARROW_API NO \
        -f PostgreSQL "$PG_CONNECTION" "$geopackage" "$source_layer" \
        "${ogr2ogr_options[@]}" || die "ogr2ogr failed loading ${source_layer}"
    layer_count=$((layer_count + 1))
done

printf 'Creating GNIS views and relationship indexes\n'
"$PSQL" "${PSQL_ARGS[@]}" \
    --set="DBSCHEMA=${DBSCHEMA}" \
    --file="$VIEWS_SQL"

printf 'Optimizing imported tables\n'
for table_name in "${!table_sources[@]}"; do
    maintain_table "$table_name"
done

printf 'GNIS load complete: %d layers and tables loaded into %s.%s.\n' \
    "$layer_count" "$DBNAME" "$DBSCHEMA"
