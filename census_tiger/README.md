# Census TIGER/Line loaders

These scripts load Census Bureau TIGER/Line data into PostgreSQL/PostGIS. The current national-level workflow uses the 2026 GeoPackage products. Older scripts in this directory handle state and county shapefile workflows.

## National GeoPackage loader

Use [`do_census_national_geopackages.sh`](do_census_national_geopackages.sh) to download and load the configured national TIGER/Line GeoPackages. It reads every layer in each GeoPackage and writes tables to the configured schema (default: `public`). Table names include the dataset prefix to distinguish similarly named layers.

```bash
./do_census_national_geopackages.sh
```

To process one dataset for recovery or a targeted update, use its prefix:

```bash
./do_census_national_geopackages.sh --process substategeo
./do_census_national_geopackages.sh --process=roads
./do_census_national_geopackages.sh --help
```

Available prefixes are `address`, `nativeamerican`, `areawater`, `blocks`, `suffixed_blocks`, `legislative`, `linearwater`, `nationgeo`, `substategeo`, `rails`, `roads`, and `school`.

The loader reuses a valid downloaded ZIP, extracts the selected archive, and imports its layers with `ogr2ogr`. It uses `-overwrite` for each imported table, so rerunning a dataset replaces those tables as they are processed. For the roads layer it requests `MULTICURVE` geometry. After import it runs `VACUUM ANALYZE`, clusters tables with a usable GiST geometry index, and finishes with `ANALYZE`; tables without a suitable geometry index are left unclustered.

Archives and extracted files are stored under `national_geopackages_2026/downloads/` and `national_geopackages_2026/extracted/`.

## Configuration and dependencies

Edit the database settings near the top of `do_census_national_geopackages.sh` for the target host, port, user, database, and schema. The script currently has a local `PGPASSWORD` assignment near the top; replace it with a protected credential setup before sharing or committing local changes. The database user needs permission to create tables and indexes in the target schema and run maintenance commands. PostGIS must be installed in the database.

Required client tools:

- Bash 4 or newer
- `wget` and `unzip`
- PostgreSQL `psql`
- GDAL `ogr2ogr` and `ogrinfo`, with PostgreSQL/PostGIS support enabled
- A PostgreSQL database with PostGIS

## Older shapefile workflows

`makecensustiger.sh`, `download.sh`, `makestates.sh`, and `doogr.sh` are older TIGER shapefile scripts. They use shapefile utilities such as `shp2pgsql` and expect Census product files in their working directory structure. Review their connection settings, year-specific URLs, and shell behavior before using them; the national GeoPackage loader above is the maintained workflow for the configured 2026 national products.
