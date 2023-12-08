#!/bin/bash

# Script to download files from the Census Bureau
shopt -s extglob
#set -x #echo on for debugging (comment to disable)
WGET="/usr/bin/wget"

# Download all the files we need (this will take a while)
$WGET -r -P AIANNH -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/AIANNH
$WGET -r -P AITSN -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/AITSN
$WGET -r -P ANRC -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/ANRC
$WGET -r -P AREALM -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/AREALM
$WGET -r -P AREAWATER -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/AREAWATER
$WGET -r -P BG -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/BG
$WGET -r -P CD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/CD
$WGET -r -P COASTLINE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/COASTLINE
$WGET -r -P CONCITY -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/CONCITY
$WGET -r -P COUNTY -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/COUNTY
$WGET -r -P COUSUB -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/COUSUB
$WGET -r -P ELSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/ELSD
$WGET -r -P ESTATE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/ESTATE
$WGET -r -P INTERNATIONALBOUNDARY -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/INTERNATIONALBOUNDARY
$WGET -r -P LINEARWATER -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/LINEARWATER
$WGET -r -P MIL -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/MIL
$WGET -r -P PLACE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/PLACE
$WGET -r -P POINTLM -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/POINTLM
$WGET -r -P PRISECROADS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/PRISECROADS
$WGET -r -P PUMA20 -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/PUMA20
$WGET -r -P RAILS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/RAILS
$WGET -r -P ROADS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/ROADS
$WGET -r -P SCSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/SCSD
$WGET -r -P SDADM -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/SDADM
$WGET -r -P SLDL -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/SLDL
$WGET -r -P SLDU -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/SLDU
$WGET -r -P STATE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/STATE
$WGET -r -P TBG -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/TBG
$WGET -r -P UAC20 -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/UAC20
$WGET -r -P UNSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/UNSD
$WGET -r -P ZCTA520 -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2023/ZCTA520
