# USGS Geographic Names Information System (GNIS)

This directory contains a loader for the USGS GNIS national GeoPackage, SQL for relationship indexes and convenience views, and an older Python utility for the former pipe-delimited NationalFile workflow.

## GNIS GeoPackage loader

Run [`do_usgs_gnis.sh`](do_usgs_gnis.sh) to download the national GeoPackage, extract it, import its layers and attribute tables, then build the views:

```bash
./do_usgs_gnis.sh
```

The script downloads `Gazetteer_National_GPKG.zip` from the USGS TNM product URL if a valid local archive is not already available. The archive and extracted GeoPackage are kept under `national_gpkg_data/downloads/` and `national_gpkg_data/extracted/`.

The loader writes into the configured schema (default: `gnis`) and replaces each imported table using `ogr2ogr -overwrite`. It disables GDAL's Arrow API to avoid failures caused by coded-value domain metadata in the source, and applies `-nlt PROMOTE_TO_MULTI` to spatial layers declared as multi geometry types. It then runs `gnis_views.sql` and performs table maintenance: `VACUUM ANALYZE`, `CLUSTER` when a geometry column has a valid GiST index, and a final `ANALYZE`. Tables without geometry or a matching GiST index skip clustering.

## Views and relationship indexes

[`gnis_views.sql`](gnis_views.sql) creates non-unique indexes for common relationship fields and views that join spatial features with names, designations, decisions, counties, states, quadrangles, and federal codes. The views use left joins so source rows with missing related records are retained. No foreign keys are added: the source has identifier gaps and duplicate/invalid relationships, so the views expose those relationships without enforcing them.

The loader drops its managed views before replacing the source tables and recreates them after import. Other objects in the target schema are not intentionally dropped.

## Configuration and dependencies

Configure the database host, port, user, database, schema, and authentication near the top of `do_usgs_gnis.sh`. Keep passwords out of committed files; the script currently has a local password assignment that should be replaced with a protected credential setup before sharing or committing local changes. The database needs PostGIS, and the database user needs permission to create or replace tables, indexes, and views and to run `VACUUM`/`CLUSTER`/`ANALYZE`.

Required tools:

- Bash 4 or newer
- `wget` and `unzip`
- PostgreSQL `psql`
- GDAL `ogr2ogr` and `ogrinfo`, with PostgreSQL/PostGIS support enabled
- A PostgreSQL database with PostGIS

## Legacy NationalFile utility

[`gnisfixer.py`](gnisfixer.py) is an older tool for filtering a pipe-delimited GNIS NationalFile to U.S. state rows. It is separate from the GeoPackage loader, expects input and output file paths, and requires the Python `us` package. The GeoPackage loader does not use it.
