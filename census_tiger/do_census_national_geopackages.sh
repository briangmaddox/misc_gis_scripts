#!/usr/bin/env bash

# Download the 2026 National-Level TIGER/Line GeoPackages and load each
# GeoPackage layer into PostGIS with ogr2ogr.
set -Eeuo pipefail

# Database and server information (edit these values before running).
DBHOST=""
DBPORT="5432"
DBUSER=""
TIGERDB=""
DBSCHEMA=""
PGPASSWORD=""
export PGPASSWORD

# Change tool names here if they are not available on PATH.
WGET="wget"
UNZIP="unzip"
PSQL="psql"
OGR2OGR="ogr2ogr"
OGRINFO="ogrinfo"

BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATADIR="${BASEDIR}/national_geopackages_2026"
DOWNLOAD_DIR="${DATADIR}/downloads"
EXTRACT_DIR="${DATADIR}/extracted"

# Dataset key | Census Bureau archive URL.
DATASETS=(
    "address|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_addr.gpkg.zip"
    "nativeamerican|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_aiarelated.gpkg.zip"
    "areawater|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_areawater.gpkg.zip"
    "blocks|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_block.gpkg.zip"
    "suffixed_blocks|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_tabblocksufx.gpkg.zip"
    "legislative|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_legislative.gpkg.zip"
    "linearwater|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_linearwater.gpkg.zip"
    "nationgeo|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_nationgeo.gpkg.zip"
    "substategeo|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_substategeo.gpkg.zip"
    "rails|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_rails.gpkg.zip"
    "roads|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_roads.gpkg.zip"
    "school|https://www2.census.gov/geo/tiger/TGRGPKG26/tlgpkg_2026_us_school.gpkg.zip"
)

# Exit function
die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

# Show usage help
usage() {
    printf 'Usage: %s [--process PREFIX]\n' "${0##*/}"
    printf '       %s --help\n' "${0##*/}"
    printf '\nProcess all datasets by default, or only the dataset matching PREFIX.\n'
    printf 'Example: %s --process substategeo\n' "${0##*/}"
    printf 'Prefixes:'
    for dataset in "${DATASETS[@]}"; do
        IFS='|' read -r dataset_key _ <<< "$dataset"
        printf ' %s' "$dataset_key"
    done
    printf '\n'
}

# Check if called with process
PROCESS_PREFIX=""
PROCESS_OPTION_SET=0
while (($#)); do
    case "$1" in
        --process)
            (($# >= 2)) || die "--process requires a dataset prefix."
            ((PROCESS_OPTION_SET == 0)) || die "Specify --process only once."
            [[ -n "$2" ]] || die "--process requires a dataset prefix."
            PROCESS_PREFIX="$2"
            PROCESS_OPTION_SET=1
            shift 2
            ;;
        --process=*)
            ((PROCESS_OPTION_SET == 0)) || die "Specify --process only once."
            PROCESS_PREFIX="${1#*=}"
            [[ -n "$PROCESS_PREFIX" ]] || die "--process requires a dataset prefix."
            PROCESS_OPTION_SET=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1 (use --help for usage)"
            ;;
    esac
done

# Set things if we're called with prefix
if [[ -n "$PROCESS_PREFIX" ]]; then
    prefix_found=0
    for dataset in "${DATASETS[@]}"; do
        IFS='|' read -r dataset_key _ <<< "$dataset"
        if [[ "$dataset_key" == "$PROCESS_PREFIX" ]]; then
            prefix_found=1
            break
        fi
    done
    ((prefix_found)) || die "Unknown dataset prefix: $PROCESS_PREFIX"
fi

# Check if our tools are installed on the system
for tool in "$WGET" "$UNZIP" "$PSQL" "$OGR2OGR" "$OGRINFO"; do
    command -v "$tool" >/dev/null 2>&1 || die "Required command not found on PATH: $tool"
done

# Check if our required variables are defined
[[ -n "$TIGERDB" ]] || die "Set TIGERDB near the top of this script."
[[ -n "$DBUSER" ]] || die "Set DBUSER near the top of this script."
[[ -n "$DBHOST" ]] || die "Set DBHOST near the top of this script."
[[ -n "$DBPORT" ]] || die "Set DBPORT near the top of this script."
[[ -n "$DBSCHEMA" ]] || die "Set DBSCHEMA near the top of this script."
[[ -n "$PGPASSWORD" ]] || die "Set PGPASSWORD near the top of this script."

# Create our download directories
mkdir -p -- "$DOWNLOAD_DIR" "$EXTRACT_DIR"

# Set our psql arguments
PSQL_ARGS=(
    --host="$DBHOST"
    --port="$DBPORT"
    --username="$DBUSER"
    --dbname="$TIGERDB"
    --set=ON_ERROR_STOP=1
    --quiet
)
PG_CONNECTION="PG:host=${DBHOST} port=${DBPORT} dbname=${TIGERDB} user=${DBUSER}"

# Check if our schema exists
printf 'Preparing schema %s in database %s\n' "$DBSCHEMA" "$TIGERDB"
"$PSQL" "${PSQL_ARGS[@]}" \
    --command="CREATE SCHEMA IF NOT EXISTS \"${DBSCHEMA}\";"

# Normalize our table names by changing spaces to _
normalize_table_name() {
    local name="${1,,}"
    name="${name//[^a-z0-9_]/_}"
    [[ "$name" =~ ^[0-9] ]] && name="census_${name}"
    name="${name:0:63}"
    printf '%s' "$name"
}

# Manage SQL literals
sql_literal() {
    local value="${1//\'/\'\'}"
    printf "'%s'" "$value"
}

# Do our post load maintanance.  Vacuum and cluster on the geospatial column
maintain_vector_table() {
    local schema="$1"
    local table_name="$2"
    local index_name
    local schema_literal table_literal

    schema_literal="$(sql_literal "$schema")"
    table_literal="$(sql_literal "$table_name")"

    printf 'Vacuum analyze %s.%s\n' "$schema" "$table_name"
    "$PSQL" "${PSQL_ARGS[@]}" \
        --command="VACUUM ANALYZE \"${schema}\".\"${table_name}\";"

    index_name="$("$PSQL" "${PSQL_ARGS[@]}" --tuples-only --no-align \
        --command="
            SELECT idx.relname
            FROM pg_index AS i
            JOIN pg_class AS tbl ON tbl.oid = i.indrelid
            JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
            JOIN pg_class AS idx ON idx.oid = i.indexrelid
            JOIN pg_am AS am ON am.oid = idx.relam
            JOIN pg_attribute AS geom ON geom.attrelid = tbl.oid
                                      AND geom.attname = 'geom'
            WHERE ns.nspname = ${schema_literal}
              AND tbl.relname = ${table_literal}
              AND am.amname = 'gist'
              AND geom.attnum = ANY (i.indkey)
              AND i.indisvalid
            ORDER BY idx.relname
            LIMIT 1;
        ")"
    if [[ -z "$index_name" ]]; then
        printf 'No valid GiST index found on %s.%s.geom; skipping CLUSTER\n' \
            "$schema" "$table_name" >&2
        cluster_skipped_count=$((cluster_skipped_count + 1))
    else
        printf 'Cluster %s.%s using GiST index %s\n' "$schema" "$table_name" "$index_name"
        "$PSQL" "${PSQL_ARGS[@]}" \
            --command="CLUSTER \"${schema}\".\"${table_name}\" USING \"${index_name}\";"
        cluster_count=$((cluster_count + 1))
    fi

    printf 'Analyze %s.%s\n' "$schema" "$table_name"
    "$PSQL" "${PSQL_ARGS[@]}" \
        --command="ANALYZE \"${schema}\".\"${table_name}\";"
}

dataset_count=0
layer_count=0
cluster_count=0
cluster_skipped_count=0
declare -A table_sources=()

for dataset in "${DATASETS[@]}"; do
    IFS='|' read -r dataset_key url <<< "$dataset"
    if [[ -n "$PROCESS_PREFIX" && "$dataset_key" != "$PROCESS_PREFIX" ]]; then
        continue
    fi
    archive_name="${url##*/}"
    archive_path="${DOWNLOAD_DIR}/${archive_name}"
    product_dir="${EXTRACT_DIR}/${dataset_key}"

    if [[ -s "$archive_path" ]] && "$UNZIP" -tq "$archive_path" >/dev/null 2>&1; then
        printf 'Using existing archive %s\n' "$archive_name"
    else
        rm -f -- "$archive_path"
        printf 'Downloading %s\n' "$archive_name"
        "$WGET" --continue --directory-prefix="$DOWNLOAD_DIR" "$url" ||
            die "Download failed: $url"
        "$UNZIP" -tq "$archive_path" >/dev/null ||
            die "Downloaded file is not a valid ZIP archive: $archive_path"
    fi

    mkdir -p -- "$product_dir"
    "$UNZIP" -oq "$archive_path" -d "$product_dir" || die "Unable to extract $archive_path"

    mapfile -d '' -t geopackages < <(find "$product_dir" -type f -iname '*.gpkg' -print0 | sort -z)
    ((${#geopackages[@]} > 0)) || die "No GeoPackage found in $archive_path"

    for geopackage in "${geopackages[@]}"; do
        layer_listing="$("$OGRINFO" -ro -q "$geopackage")" ||
            die "Could not list layers in $geopackage"
        source_layers=()
        while IFS= read -r layer_info; do
            if [[ "$layer_info" =~ ^[[:space:]]*[0-9]+:[[:space:]](.+)[[:space:]]\([^()]*\)[[:space:]]*$ ]]; then
                source_layers+=("${BASH_REMATCH[1]}")
            fi
        done <<< "$layer_listing"
        ((${#source_layers[@]} > 0)) || die "No layers found in $geopackage"

        for source_layer in "${source_layers[@]}"; do
            table_name="$(normalize_table_name "${dataset_key}_${source_layer}")"
            source_id="${dataset_key}/${source_layer}"
            if [[ -n "${table_sources[$table_name]+present}" ]]; then
                die "Table name collision: ${table_sources[$table_name]} and ${source_id} both map to ${DBSCHEMA}.${table_name}"
            fi
            table_sources[$table_name]="$source_id"
            ogr2ogr_options=(
                -nln "$table_name"
                -overwrite
                -lco "SCHEMA=${DBSCHEMA}"
                -lco GEOMETRY_NAME=geom
                -lco SPATIAL_INDEX=GIST
            )
            if [[ "$dataset_key" == "roads" && "${source_layer,,}" == "roads" ]]; then
                printf 'Coercing %s layer %s to MULTICURVE\n' "$archive_name" "$source_layer"
                ogr2ogr_options+=(-nlt MULTICURVE)
            fi
            printf 'Loading %s layer %s -> %s.%s\n' \
                "$archive_name" "$source_layer" "$DBSCHEMA" "$table_name"
            "$OGR2OGR" -f PostgreSQL "$PG_CONNECTION" "$geopackage" "$source_layer" \
                "${ogr2ogr_options[@]}" || die "ogr2ogr failed loading ${source_layer} from ${geopackage}"
            maintain_vector_table "$DBSCHEMA" "$table_name"
            layer_count=$((layer_count + 1))
        done
    done
    dataset_count=$((dataset_count + 1))
done

printf 'Census national GeoPackage load complete: %d archives and %d layers loaded into %s.%s.\n' \
    "$dataset_count" "$layer_count" "$TIGERDB" "$DBSCHEMA"
printf 'Post-load clustering complete: %d tables clustered; %d skipped because no valid GiST index was found.\n' \
    "$cluster_count" "$cluster_skipped_count"
