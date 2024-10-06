#!/bin/bash

# Script to download files from the Census Bureau
shopt -s extglob
#set -x #echo on for debugging (comment to disable)
WGET="/usr/bin/wget"

# Download all the files we need (this will take a while)
$WGET -r -P AIANNH -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/AIANNH
$WGET -r -P AITSN -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/AITSN
$WGET -r -P ANRC -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/ANRC
$WGET -r -P AREALM -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/AREALM
$WGET -r -P AREAWATER -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/AREAWATER
$WGET -r -P BG -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/BG
$WGET -r -P CD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/CD
$WGET -r -P COASTLINE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/COASTLINE
$WGET -r -P CONCITY -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/CONCITY
$WGET -r -P COUNTY -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/COUNTY
$WGET -r -P COUSUB -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/COUSUB
$WGET -r -P ELSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/ELSD
$WGET -r -P ESTATE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/ESTATE
$WGET -r -P INTERNATIONALBOUNDARY -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/INTERNATIONALBOUNDARY
$WGET -r -P LINEARWATER -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/LINEARWATER
$WGET -r -P MIL -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/MIL
$WGET -r -P PLACE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/PLACE
$WGET -r -P POINTLM -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/POINTLM
$WGET -r -P PRISECROADS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/PRISECROADS
$WGET -r -P PUMA20 -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/PUMA20
$WGET -r -P RAILS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/RAILS
$WGET -r -P ROADS -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/ROADS
$WGET -r -P SCSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/SCSD
$WGET -r -P SDADM -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/SDADM
$WGET -r -P SLDL -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/SLDL
$WGET -r -P SLDU -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/SLDU
$WGET -r -P STATE -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/STATE
$WGET -r -P TBG -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/TBG
$WGET -r -P UAC20 -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/UAC20
$WGET -r -P UNSD -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/UNSD
$WGET -r -P ZCTA520 -nH --cut-dirs=100 --inet4-only ftp://ftp2.census.gov/geo/tiger/TIGER2024/ZCTA520
