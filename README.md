# Miscellaneous GIS scripts

A collection of shell and Python utilities for downloading, preparing, and loading public GIS data into PostgreSQL/PostGIS. The scripts are maintained as practical tools for a local GIS environment; check each script and its source data before adapting it for another deployment.

## Loaders

| Directory | Purpose | Start here |
| --- | --- | --- |
| [`census_tiger/`](census_tiger/README.md) | Load national Census TIGER/Line GeoPackages into PostGIS, or use the older TIGER shapefile workflows. | `census_tiger/do_census_national_geopackages.sh` |
| [`usgs_gnis/`](usgs_gnis/README.md) | Load the USGS GNIS National GeoPackage and create convenience views. | `usgs_gnis/do_usgs_gnis.sh` |
| `natural_earth/` | Load Natural Earth vector and raster data into separate PostGIS schemas. | `natural_earth/donaturalearth.sh` |
| `geonames/` | Older GeoNames text-dump loader and table definitions. | `geonames/dogeonames.sh` |

## Natural Earth

Configure the connection variables near the top of `natural_earth/donaturalearth.sh`, then run:

```bash
./natural_earth/donaturalearth.sh
```

The optional `--continue` flag skips tables that already exist and contain rows. The loader downloads Natural Earth vector and raster archives and loads them into the `cultural`, `physical`, and `raster` schemas. It requires Bash, `wget`, `unzip`, `psql`, `shp2pgsql`, and `raster2pgsql`, plus PostgreSQL with PostGIS and PostGIS raster support. The database user must be able to create the needed schemas/extensions or those extensions must already be installed.

## GeoNames legacy loader

`geonames/dogeonames.sh` downloads the GeoNames text dumps, creates tables using `geonames/create_tables.sql`, and imports the files. Configure the connection variables in the script before running it. It requires `wget`, `unzip`, `psql`, and a PostgreSQL database with PostGIS. This is an older script; review its source URLs, SQL, and database effects before use.

## General requirements

The loaders generally require Bash, `wget`, `unzip`, PostgreSQL client tools such as `psql`, and a reachable PostgreSQL server with PostGIS installed. Depending on the loader, you may also need GDAL tools (`ogr2ogr`, `ogrinfo`), `shp2pgsql`, and `raster2pgsql`. See the relevant directory README or script usage text for configuration details.

Configure the database host, port, user, database, schema, and authentication before running a loader. Keep passwords and other local credentials out of committed files. Most scripts download archives and store them beneath their own data directory, so allow enough disk space for both compressed and extracted data.

## Notes

- Loaders may replace tables they own. Read the per-loader overwrite and resume behavior before running against a database with existing data.
- Data providers can change schemas, geometry types, URLs, and release versions. The scripts target the releases described in their directory documentation.
- These scripts are independent utilities rather than a packaged Python application; run them from any directory using their path, for example `./census_tiger/do_census_national_geopackages.sh`.
