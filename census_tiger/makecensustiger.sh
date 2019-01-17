#!/bin/bash

# Master script to create my Census TIGER db
shopt -s extglob
#set -x #echo on for debugging (comment to disable)

# Database to write to
DBHOST=""
DBPORT="5432"
DBUSER=""
TIGERDB=""

# Don't whine to me about security, do it differently if you want
export PGPASSWORD=""

# Source directory
BASEDIR=$(dirname "${BASH_SOURCE[0]}")

# Top level directory
TOPDIR=$(pwd)

# Change these for your local system
SHP2PGSQL="/usr/bin/shp2pgsql"
WGET="/usr/bin/wget"
PSQL="/usr/bin/psql -q"
DOOGR="${BASEDIR}/doogr.sh"
MAKESTATES="${BASEDIR}/makestates.sh"

# Download all the files we need (this will take a while)
#$WGET -r -P AIANNH -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/AIANNH
#$WGET -r -P ANRC -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/ANRC
#$WGET -r -P AREALM -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/AREALM
#$WGET -r -P AREAWATER -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/AREAWATER
#$WGET -r -P BG -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/BG
#$WGET -r -P CD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/CD
#$WGET -r -P CONCITY -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/CONCITY
#$WGET -r -P COUNTY -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/COUNTY
#$WGET -r -P COUSUB -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/COUSUB
#$WGET -r -P ELSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/ELSD
#$WGET -r -P LINEARWATER -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/LINEARWATER
#$WGET -r -P MIL -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/MIL
#$WGET -r -P PLACE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/PLACE
#$WGET -r -P POINTLM -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/POINTLM
#$WGET -r -P PRISECROADS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/PRISECROADS
#$WGET -r -P PUMA -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/PUMA
#$WGET -r -P RAILS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/RAILS
#$WGET -r -P ROADS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/ROADS
#$WGET -r -P SCSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/SCSD
#$WGET -r -P SLDL -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/SLDL
#$WGET -r -P SLDU -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/SLDU
#$WGET -r -P STATE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/STATE
#$WGET -r -P UNSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/UNSD
#$WGET -r -P ZCTA5 -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2018/ZCTA5

# *****************************************************************************
# Process the American Indian / Alaska Native / Native Hawaiian Areas
echo "****************************************************************************"
echo "Now processing the American Indian / Alaska Native / Native Hawaiian Areas table"
cd AIANNH
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I tl*.shp american_indian_alaska_native_native_hawaiian_areas | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}

# Optimize the DB
echo "Optimizing the table american_indian_alaska_native_native_hawaiian_areas"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE american_indian_alaska_native_native_hawaiian_areas"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER american_indian_alaska_native_native_hawaiian_areas USING american_indian_alaska_native_native_hawaiian_areas_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE american_indian_alaska_native_native_hawaiian_areas"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm *.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Alaska Native Regional Corporation
echo "****************************************************************************"
echo "Now processing the Alaska Native Regional Corporation table"
cd ANRC
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I tl*.shp alaska_native_regional_corporations | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}

# Optimize the DB
echo "Optimizing the table alaska_native_regional_corporations"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE alaska_native_regional_corporations"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER alaska_native_regional_corporations USING alaska_native_regional_corporations_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE alaska_native_regional_corporations"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm *.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Area Landmarks
echo "****************************************************************************"
echo "Now processing the Area Landmarks table"
cd AREALM
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir arealm
cd arealm
echo "Creating the country-level shapefile"
. $DOOGR arealm.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I arealm.shp area_landmarks | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table area_landmarks"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE area_landmarks"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER area_landmarks USING area_landmarks_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE area_landmarks"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Area Water
echo "****************************************************************************"
echo "Now processing the Area Water table"
cd AREAWATER
. $MAKESTATES area_water

# Optimize the DB
echo "Optimizing the table area_water"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE area_water"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER area_water USING area_water_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE area_water"

# Go back to our top level directory
cd $TOPDIR

# ****************************************************************************
echo "***************************************************************************"
echo "Now processing the Block Groups table"
cd BG
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir bgroups
cd bgroups
echo "Creating the country-level shapefile"
. $DOOGR bgroups.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I bgroups.shp block_groups | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table block_groups"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE block_groups"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER block_groups USING block_groups_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE block_groups"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# ****************************************************************************
echo "***************************************************************************"
echo "Now processing the Congressional Districts table"
cd CD
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I tl*.shp congressional_districts | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}

# Optimize the DB
echo "Optimizing the table congressional_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE congressional_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER congressional_districts USING congressional_districts_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE congressional_districts"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Consolidated Cities
echo "****************************************************************************"
echo "Now processing the Consolidated Cities table"
cd CONCITY
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir concity
cd concity
echo "Creating the country-level shapefile"
. $DOOGR concity.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I concity.shp consolidated_cities | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table consolidated_cities"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE consolidated_cities"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER consolidated_cities USING consolidated_cities_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE consolidated_cities"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the County Subdivisions
echo "****************************************************************************"
echo "Now processing the County Subdivisions table"
cd COUSUB
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir cousub
cd cousub
echo "Creating the country-level shapefile"
. $DOOGR cousub.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I cousub.shp county_subdivisions | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table county_subdivisions"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE county_subdivisions"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER county_subdivisions USING county_subdivisions_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE county_subdivisions"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Elementary School Districts
echo "****************************************************************************"
echo "Now processing the Elementary School Districts table"
cd ELSD
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir elsd
cd elsd
echo "Creating the country-level shapefile"
. $DOOGR elsd.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I elsd.shp elementary_school_districts | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table elementary_school_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE elementary_school_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER elementary_school_districts USING elementary_school_districts_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE elementary_school_districts"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Linear Water
echo "****************************************************************************"
echo "Now processing the Linear Water table"
cd LINEARWATER
. $MAKESTATES linear_water

# Optimize the DB
echo "Optimizing the table linear_water"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE linear_water"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER linear_water USING linear_water_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE linear_water"

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Military Installations
echo "****************************************************************************"
echo "Now processing the Military Installations table"
cd MIL
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I tl*.shp military_installations | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}

# Optimize the DB
echo "Optimizing the table military_installations"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE military_installations"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER military_installations USING military_installations_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE military_installations"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm *.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Places
echo "****************************************************************************"
echo "Now processing the Places table"
cd PLACE
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir place
cd place
echo "Creating the country-level shapefile"
. $DOOGR place.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I place.shp places | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table places"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE places"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER places USING places_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE places"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Point Landmarks
echo "****************************************************************************"
echo "Now processing the Point Landmarks table"
cd POINTLM
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir pointlm
cd pointlm
echo "Creating the country-level shapefile"
. $DOOGR pointlm.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I pointlm.shp point_landmarks | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table point_landmarks"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE point_landmarks"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER point_landmarks USING point_landmarks_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE point_landmarks"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Primary/Secondary Roads
echo "****************************************************************************"
echo "Now processing the Primary/Secondary Roads table"
cd PRISECROADS
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir prisecroads
cd prisecroads
echo "Creating the country-level shapefile"
. $DOOGR prisecroads.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I prisecroads.shp prisec_roads | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table prisec_roads"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE prisec_roads"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER prisec_roads USING prisec_roads_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE prisec_roads"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Public Use Microdata Areas
echo "****************************************************************************"
echo "Now processing the Public Use Microdata Areas table"
cd PUMA
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir puma
cd puma
echo "Creating the country-level shapefile"
. $DOOGR puma.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I puma.shp public_use_microdata_areas | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table public_use_microdata_areas"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE public_use_microdata_areas"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER public_use_microdata_areas USING public_use_microdata_areas_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE public_use_microdata_areas"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Railroads
echo "****************************************************************************"
echo "Now processing the Railroads table"
cd RAILS
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I tl*.shp railroads | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}

# Optimize the DB
echo "Optimizing the table railroads"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE railroads"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER railroads USING railroads_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE railroads"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm *.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Roads
echo "****************************************************************************"
echo "Now processing the Roads table"
cd ROADS
. $MAKESTATES roads

# Optimize the DB
echo "Optimizing the table roads"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE roads"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER roads USING roads_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE roads"

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Secondary School Districts
echo "****************************************************************************"
echo "Now processing the Secondary School Districts table"
cd SCSD
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir scsd
cd scsd
echo "Creating the country-level shapefile"
. $DOOGR scsd.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I scsd.shp secondary_school_districts | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table secondary_school_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE secondary_school_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER secondary_school_districts USING secondary_school_districts_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE secondary_school_districts"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the State Legislative Lower Districts
echo "****************************************************************************"
echo "Now processing the State Legislative Lower Districts table"
cd SLDL
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir sldl
cd sldl
echo "Creating the country-level shapefile"
. $DOOGR sldl.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I sldl.shp state_legislative_lower_districts | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table state_legislative_lower_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE state_legislative_lower_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER state_legislative_lower_districts USING state_legislative_lower_districts_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE state_legislative_lower_districts"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the State Legislative Upper Districts
echo "****************************************************************************"
echo "Now processing the State Legislative Upper Districts table"
cd SLDU
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir sldu
cd sldu
echo "Creating the country-level shapefile"
. $DOOGR sldu.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I sldu.shp state_legislative_upper_districts | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table state_legislative_upper_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE state_legislative_upper_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER state_legislative_upper_districts USING state_legislative_upper_districts_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE state_legislative_upper_districts"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the Unified School Districts
echo "****************************************************************************"
echo "Now processing the Unified School Districts table"
cd UNSD
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Creating the output directory"
mkdir unsd
cd unsd
echo "Creating the country-level shapefile"
. $DOOGR unsd.shp ../*.shp
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I unsd.shp unified_school_districts | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
cd ..

# Optimize the DB
echo "Optimizing the table unified_school_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE unified_school_districts"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER unified_school_districts USING unified_school_districts_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE unified_school_districts"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm tl*.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the ZIP Code Tabulation Areas
echo "****************************************************************************"
echo "Now processing the Railroads table"
cd ZCTA5
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I tl*.shp zip_codes | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}

# Optimize the DB
echo "Optimizing the table zip_codes"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE zip_codes"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER zip_codes USING zip_codes_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE zip_codes"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm *.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the County Boundaries
echo "****************************************************************************"
echo "Now processing the County Boundaries table"
cd COUNTY
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I tl*.shp county_boundaries | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}

# Optimize the DB
echo "Optimizing the table county_boundaries"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE county_boundaries"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER county_boundaries USING county_boundaries_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE county_boundaries"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm *.!(zip)

# Go back to our top level directory
cd $TOPDIR

# *****************************************************************************
# Process the State Boundaries
echo "****************************************************************************"
echo "Now processing the State Boundaries table"
cd STATE
echo "Unzipping the files."
for foo in *.zip; do unzip -q $foo; done
echo "Running shp2pgsql"
${SHP2PGSQL} -s 4269 -c -I tl*.shp state_boundaries | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}

# Optimize the DB
echo "Optimizing the table state_boundaries"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "VACUUM ANALYZE state_boundaries"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "CLUSTER state_boundaries USING state_boundaries_geom_idx"
$PSQL --host=$DBHOST --port=$DBPORT --username=$DBUSER --dbname=$TIGERDB -c "ANALYZE state_boundaries"

# Clean up after ourselves
echo "Cleaning up temporary files"
rm *.!(zip)

# Go back to our top level directory
cd $TOPDIR

echo "The database should be complete now"
