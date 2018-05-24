#!/bin/bash

# Master script to create my Geonames db
shopt -s extglob
set -x #echo on for debugging (comment to disable)

# Database and server information
DBHOST=""
GEONAMESDB="geonames"

# Don't whine to me about security, do it differently if you want
export PGPASSWORD=""

# Source directory
BASEDIR=$(dirname "${BASH_SOURCE[0]}")

# Change these for your local system
WGET="/usr/bin/wget"
PSQL="/usr/bin/psql -q"
UNZIP="/usr/bin/unzip"

# Download the files we need.
$WGET http://download.geonames.org/export/dump/allCountries.zip
$WGET http://download.geonames.org/export/dump/featureCodes_en.txt
$WGET http://download.geonames.org/export/dump/alternateNames.zip
$WGET http://download.geonames.org/export/dump/admin1CodesASCII.txt
$WGET http://download.geonames.org/export/dump/admin2Codes.txt
$WGET http://download.geonames.org/export/dump/adminCode5.zip
$WGET http://download.geonames.org/export/dump/countryInfo.txt
$WGET http://download.geonames.org/export/dump/hierarchy.zip
$WGET http://download.geonames.org/export/dump/timeZones.txt
$WGET http://download.geonames.org/export/dump/userTags.zip

# Unzip them
$UNZIP allCountries.zip
$UNZIP alternateNames.zip
$UNZIP adminCode5.zip
$UNZIP hierarchy.zip
$UNZIP userTags.zip

# Make the tables
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -f "$BASEDIR/create_tables.sql"

# Geoname table
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy geoname from allCountries.txt null as '';"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "SELECT AddGeometryColumn( 'geoname', 'the_geom', 4326, 'POINT', 2);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "update geoname SET the_geom = ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index geoname_the_geom_gist_idx on geoname using gist (the_geom);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index geoname_geonameid_idx on geoname(geonameid);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index geoname_name_idx on geoname(name);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze geoname;"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "cluster geoname using geoname_the_geom_gist_idx;"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "analyze geoname;"

# alternateNames table
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy alternatename from alternateNames.txt null as '';"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index alternatename_alternatenameid_idx on alternatename(alternatenameid);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index alternatename_geonameid_idx on alternatename(geonameid);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze alternatename;"

# isolanguagecodes
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy isolanguage from iso-languagecodes.txt null '' delimiter E'\t' csv header;"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze isolanguage;"

# countryinfo
egrep -v "^[[:blank:]]*#" countryInfo.txt > countryInfo2.txt
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy countryinfo from countryInfo2.txt null as '';"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index countryinfo_geonameid_idx on countryinfo(geonameid);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze countryinfo;"

# timezones
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy timezones from timeZones.txt null '' delimiter E'\t' csv header;"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index timezones_countrycode_idx on timezones(countrycode);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze timezones;"

# admin1codesascii
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy admin1codesascii from admin1CodesASCII.txt null as '';"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index admin1codesascii_geonameid_idx on admin1codesascii(geonameid);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze admin1codesascii;"

# admin2codes
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy admin2codes from admin2Codes.txt null as '';"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index admin2codes_geonameid_idx on admin2codes(geonameid);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze admin2codes;"

# featurecodes
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy featurecodes from featureCodes_en.txt null as '';"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index featurecodes_code_idx on featurecodes(code);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze featurecodes;"

# usertags
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy usertags from userTags.txt null as '';"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index usertags_geonameid_idx on usertags(geonameid);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze usertags;"

# hierarchy
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy hierarchy from hierarchy.txt null as '';"

# admincode5
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "\copy admincode5 from adminCode5.txt null as '';"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "create index admincode5_geonameid_idx on admincode5(geonameid);"
$PSQL --host=$DBHOST --dbname=$GEONAMESDB -c "vacuum analyze admincode5;"
