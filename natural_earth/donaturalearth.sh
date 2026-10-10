#!/usr/bin/env bash
# Download the configured Natural Earth datasets and load them into PostGIS.
set -Eeuo pipefail

CONTINUE_MODE=0
if (($# > 1)); then
    printf 'Usage: %s [--continue]\n' "${0##*/}" >&2
    exit 2
fi
if (($# == 1)); then
    case "$1" in
        --continue) CONTINUE_MODE=1 ;;
        -h|--help)
            printf 'Usage: %s [--continue]\n' "${0##*/}"
            printf '  --continue  Skip tables that already exist and contain at least one row.\n'
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\nUsage: %s [--continue]\n' "$1" "${0##*/}" >&2
            exit 2
            ;;
    esac
fi

# Database and server information (edit these values before running).
DBHOST=""
DBPORT="5432"
DBUSER=""
NATURALEARTHDB=""
PGPASSWORD=""
export PGPASSWORD

# Change tool names here if they are not available on PATH.
WGET="wget"
UNZIP="unzip"
PSQL="psql"
SHP2PGSQL="shp2pgsql"
RASTER2PGSQL="raster2pgsql"

BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATADIR="${BASEDIR}/data"
DOWNLOAD_DIR="${DATADIR}/downloads"
EXTRACT_DIR="${DATADIR}/extracted"

# Dataset theme | table name ('auto' uses each vector file name) | archive URL.
DATASETS=(
    # Cultural
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_sovereignty.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_map_units.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_map_subunits.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_scale_rank.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_scale_rank_minor_islands.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_boundary_lines_land.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_boundary_lines_map_units.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_boundary_lines_maritime_indicator.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_boundary_lines_maritime_indicator_chn.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_pacific_groupings.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_disputed_areas.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_disputed_areas_scale_rank_minor_islands.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_boundary_lines_disputed_areas.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_antarctic_claims.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_antarctic_claim_limit_lines.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces_scale_rank.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces_lakes.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces_lines.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_2_counties.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_2_counties_scale_rank.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_2_counties_scale_rank_minor_islands.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_roads.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_roads_north_america.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_railroads.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_railroads_north_america.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_airports.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_ports.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_urban_areas.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_parks_and_protected_lands.zip"
    "cultural|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_time_zones.zip"
    # Physical
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_coastline.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_land.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_land_scale_rank.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_minor_islands.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_minor_islands_coastline.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_reefs.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_ocean.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_ocean_scale_rank.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_rivers_lake_centerlines.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_rivers_lake_centerlines_scale_rank.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_rivers_australia.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_rivers_europe.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_rivers_north_america.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_lakes.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_lakes_historic.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_lakes_pluvial.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_lakes_australia.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_lakes_europe.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_lakes_north_america.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_geography_regions_polys.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_geography_regions_points.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_geography_regions_elevation_points.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_geography_marine_polys.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_playas.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_antarctic_ice_shelves_polys.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_antarctic_ice_shelves_lines.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_glaciated_areas.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_bathymetry_all.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_geographic_lines.zip"
    "physical|auto|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_graticules_all.zip"
    # Raster
    "raster|cross_blended_hypso|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/HYP_HR.zip"
    "raster|cross_blended_hypso_shaded_relief|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/HYP_HR_SR.zip"
    "raster|cross_blended_hypso_shaded_relief_and_water|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/HYP_HR_SR_W.zip"
    "raster|cross_blended_hypso_shaded_relief_water_and_drainages|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/HYP_HR_SR_W_DR.zip"
    "raster|cross_blended_hypso_relief_water_drains_and_ocean_bottom|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/HYP_HR_SR_OB_DR.zip"
    "raster|natural_earth_i|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE1_HR_LC.zip"
    "raster|natural_earth_i_shaded_relief|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE1_HR_LC_SR.zip"
    "raster|natural_earth_i_shaded_relief_and_water|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE1_HR_LC_SR_W.zip"
    "raster|natural_earth_i_shaded_relief_water_and_drainages|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE1_HR_LC_SR_W_DR.zip"
    "raster|natural_earth_ii|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE2_HR_LC.zip"
    "raster|natural_earth_ii_shaded_relief|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE2_HR_LC_SR.zip"
    "raster|natural_earth_ii_shaded_relief_and_water|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE2_HR_LC_SR_W.zip"
    "raster|natural_earth_ii_shaded_relief_water_and_drainages|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE2_HR_LC_SR_W_DR.zip"
    "raster|ocean_bottom|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/OB_LR.zip"
    "raster|shaded_relief_basic|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/SR_HR.zip"
    "raster|gray_earth|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/GRAY_HR_SR.zip"
    "raster|gray_earth_shaded_relief_hypsography_and_flat_water|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/GRAY_HR_SR_W.zip"
    "raster|gray_earth_shaded_relief_hypsography_and_ocean_bottom|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/GRAY_HR_SR_OB.zip"
    "raster|gray_earth_shaded_relief_hypsography_ocean_bottom_and_drainages|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/GRAY_HR_SR_OB_DR.zip"
    "raster|manual_shaded_relief_contiguous_us|https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/US_MSR_10M.zip"
)

# Exit function
die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

# Check if our tools are installed on the system
for tool in "$WGET" "$UNZIP" "$PSQL" "$SHP2PGSQL" "$RASTER2PGSQL"; do
    command -v "$tool" >/dev/null 2>&1 || die "Required command not found on PATH: $tool"
done

# Check if our required variables are defined
[[ -n "$NATURALEARTHDB" ]] || die "Set NATURALEARTHDB near the top of this script."
[[ -n "$DBHOST" ]] || die "Set DBHOST near the top of this script."
[[ -n "$DBPORT" ]] || die "Set DBPORT near the top of this script."
[[ -n "$DBUSER" ]] || die "Set DBUSER near the top of this script."
[[ -n "$PGPASSWORD" ]] || die "Set PGPASSWORD near the top of this script."

# Create our download directories
mkdir -p -- "$DOWNLOAD_DIR/cultural" "$DOWNLOAD_DIR/physical" "$DOWNLOAD_DIR/raster"
mkdir -p -- "$EXTRACT_DIR/cultural" "$EXTRACT_DIR/physical" "$EXTRACT_DIR/raster"

# Set our psql arguments
PSQL_ARGS=(
    --host="$DBHOST"
    --port="$DBPORT"
    --username="$DBUSER"
    --dbname="$NATURALEARTHDB"
    --set=ON_ERROR_STOP=1
    --quiet
)

# Set up the extensions and schemas in case they're not there
printf 'Preparing schemas in database %s\n' "$NATURALEARTHDB"
"$PSQL" "${PSQL_ARGS[@]}" --command='
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_raster;
    CREATE SCHEMA IF NOT EXISTS cultural;
    CREATE SCHEMA IF NOT EXISTS physical;
    CREATE SCHEMA IF NOT EXISTS raster;
'

# Normalize our table names by changing spaces to _
normalize_table_name() {
    local name="${1,,}"
    name="${name//[^a-z0-9_]/_}"
    [[ "$name" =~ ^[0-9] ]] && name="ne_${name}"
    printf '%s' "$name"
}

# Drop the table if it exists
drop_managed_table() {
    local schema="$1"
    local table_name="$2"
    "$PSQL" "${PSQL_ARGS[@]}" \
        --command="DROP TABLE IF EXISTS \"${schema}\".\"${table_name}\";"
}

# Do our post load maintanance.  Vacuum and cluster on the geospatial column
maintain_vector_table() {
    local schema="$1"
    local table_name="$2"
    local index_name

    printf 'Vacuum analyze %s.%s\n' "$schema" "$table_name"
    "$PSQL" "${PSQL_ARGS[@]}" \
        --command="VACUUM ANALYZE \"${schema}\".\"${table_name}\";"

    index_name="$("$PSQL" "${PSQL_ARGS[@]}" --tuples-only --no-align --command="
        SELECT idx.relname
        FROM pg_index AS i
        JOIN pg_class AS tbl ON tbl.oid = i.indrelid
        JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
        JOIN pg_class AS idx ON idx.oid = i.indexrelid
        JOIN pg_am AS am ON am.oid = idx.relam
        JOIN pg_attribute AS geom ON geom.attrelid = tbl.oid AND geom.attname = 'geom'
        WHERE ns.nspname = '${schema}'
          AND tbl.relname = '${table_name}'
          AND am.amname = 'gist'
          AND geom.attnum = ANY (i.indkey)
          AND i.indisvalid
        ORDER BY idx.relname
        LIMIT 1;
    ")"
    [[ -n "$index_name" ]] || die "No valid GiST index found on ${schema}.${table_name}.geom"

    printf 'Cluster %s.%s using GiST index %s\n' "$schema" "$table_name" "$index_name"
    "$PSQL" "${PSQL_ARGS[@]}" \
        --command="CLUSTER \"${schema}\".\"${table_name}\" USING \"${index_name}\";"

    printf 'Analyze %s.%s\n' "$schema" "$table_name"
    "$PSQL" "${PSQL_ARGS[@]}" \
        --command="ANALYZE \"${schema}\".\"${table_name}\";"
}

# Download the file from natural earth  We have to use a referer since they have it set up to reject direct downloads.
download_archive() {
    local url="$1"
    local destination="$2"
    local referer="$3"
    if [[ -s "$destination" ]] && "$UNZIP" -tq "$destination" >/dev/null 2>&1; then
        printf 'Using existing download %s\n' "$(basename -- "$destination")"
    else
        rm -f -- "$destination" "$destination.part"
        printf 'Downloading %s\n' "$(basename -- "$destination")"
        "$WGET" --quiet --show-progress --referer="$referer" \
            --output-document="$destination.part" "$url" || {
            rm -f -- "$destination.part"
            die "Download failed: $url"
        }
        mv -- "$destination.part" "$destination"
        "$UNZIP" -tq "$destination" >/dev/null || die "Downloaded file is not a valid ZIP archive: $destination"
    fi
}

# Check if an existing table has any rows to see if we finished or had an error previously
table_has_rows() {
    local schema="$1"
    local table_name="$2"
    local exists rows

    exists="$("$PSQL" "${PSQL_ARGS[@]}" --tuples-only --no-align \
        --set=schema="$schema" --set=table="$table_name" \
        --command="SELECT to_regclass(format('%I.%I', :'schema', :'table')) IS NOT NULL;")"
    [[ "$exists" == t ]] || return 1

    rows="$("$PSQL" "${PSQL_ARGS[@]}" --tuples-only --no-align \
        --command="SELECT EXISTS (SELECT 1 FROM \"${schema}\".\"${table_name}\" LIMIT 1);")"
    [[ "$rows" == t ]]
}

# Load up the vector data (cultural and physical)
load_vector_archive() {
    local schema="$1"
    local url="$2"
    local referer
    local archive_name="${url##*/}"
    local archive_stem="${archive_name%.*}"
    local archive_path="$DOWNLOAD_DIR/$schema/$archive_name"
    local product_dir="$EXTRACT_DIR/$schema/$archive_stem"
    local source source_stem table_name
    local -a shapefiles=()

    case "$schema" in
        cultural) referer="https://www.naturalearthdata.com/downloads/10m-cultural-vectors/" ;;
        physical) referer="https://www.naturalearthdata.com/downloads/10m-physical-vectors/" ;;
        *) die "Unsupported vector schema: $schema" ;;
    esac

    download_archive "$url" "$archive_path" "$referer"
    mkdir -p -- "$product_dir"
    "$UNZIP" -oq "$archive_path" -d "$product_dir" || die "Unable to extract $archive_path"

    mapfile -d '' -t shapefiles < <(find "$product_dir" -type f -iname '*.shp' -print0 | sort -z)
    (("${#shapefiles[@]}")) || die "No shapefile found in $archive_path"

    for source in "${shapefiles[@]}"; do
        source_stem="$(basename -- "$source")"
        source_stem="${source_stem%.*}"
        table_name="$(normalize_table_name "$source_stem")"

# With continue, see if the current table exists and has rows in it.
if (( CONTINUE_MODE )) && table_has_rows "$schema" "$table_name"; then
    printf 'Skipping populated table %s.%s (--continue)\n' "$schema" "$table_name"
    skipped_count=$((skipped_count + 1))
    continue
fi

printf 'Loading vector %s -> %s.%s\n' "$source" "$schema" "$table_name"
        drop_managed_table "$schema" "$table_name"
        "$SHP2PGSQL" -c -I -s 4326 "$source" "${schema}.${table_name}" |
            "$PSQL" "${PSQL_ARGS[@]}"
        maintain_vector_table "$schema" "$table_name"
        vector_count=$((vector_count + 1))
    done
}
# Load our raster data
load_raster_archive() {
    local url="$1"
    local table_override="$2"
    local archive_name="${url##*/}"
    local archive_stem="${archive_name%.*}"
    local archive_path="$DOWNLOAD_DIR/raster/$archive_name"
    local product_dir="$EXTRACT_DIR/raster/$archive_stem"
    local source source_stem table_name
    local -a raster_files=()

    download_archive "$url" "$archive_path" \
        "https://www.naturalearthdata.com/downloads/10m-raster-data/"
    mkdir -p -- "$product_dir"
    "$UNZIP" -oq "$archive_path" -d "$product_dir" || die "Unable to extract $archive_path"

    # Natural Earth packages GeoTIFFs inside nested product directories, so
    # search recursively from the per-archive extraction directory.
    mapfile -d '' -t raster_files < <(find "$product_dir" -type f -iname '*.tif' -print0 | sort -z)
    (("${#raster_files[@]}")) || die "No supported raster image found in $archive_path"

    for source in "${raster_files[@]}"; do
        source_stem="$(basename -- "$source")"
        source_stem="${source_stem%.*}"
        if [[ -n "$table_override" && "${#raster_files[@]}" -eq 1 ]]; then
            table_name="$(normalize_table_name "$table_override")"
        elif [[ -n "$table_override" ]]; then
            table_name="$(normalize_table_name "${table_override}_${source_stem}")"
        elif [[ "${#raster_files[@]}" -eq 1 ]]; then
            table_name="$(normalize_table_name "$archive_stem")"
        else
            table_name="$(normalize_table_name "${archive_stem}_${source_stem}")"
        fi

# As with vector, if we continue check if the table exists and has been populated.
if (( CONTINUE_MODE )) && table_has_rows raster "$table_name"; then
    printf 'Skipping populated table raster.%s (--continue)\n' "$table_name"
    skipped_count=$((skipped_count + 1))
    continue
fi

printf 'Loading raster %s -> raster.%s\n' "$source" "$table_name"
        drop_managed_table raster "$table_name"
        "$RASTER2PGSQL" -c -I -C -M -s 4326 -t 256x256 "$source" "raster.${table_name}" |
            "$PSQL" "${PSQL_ARGS[@]}"
        raster_count=$((raster_count + 1))
    done
}

vector_count=0
raster_count=0
url_count=0
skipped_count=0

for dataset in "${DATASETS[@]}"; do
    IFS='|' read -r theme table_name url <<< "$dataset"
    case "$theme" in
        cultural|physical)
            load_vector_archive "$theme" "$url"
            ;;
        raster)
            [[ -n "$table_name" && "$table_name" != auto ]] ||
                die "Raster dataset requires an explicit table name: $url"
            load_raster_archive "$url" "$table_name"
            ;;
        *)
            die "Unsupported dataset theme '$theme' in DATASETS"
            ;;
    esac
    url_count=$((url_count + 1))
done

(( url_count > 0 )) || die "No datasets are configured in DATASETS."

printf 'Natural Earth load complete: %d datasets processed, %d vector tables and %d raster tables loaded into %s.\n' \
    "$url_count" "$vector_count" "$raster_count" "$NATURALEARTHDB"
if (( CONTINUE_MODE )); then
    printf 'Skipped %d existing populated tables.\n' "$skipped_count"
fi
