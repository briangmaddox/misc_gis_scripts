#!/bin/bash

#set -x #echo on for debugging (comment to disable)

# Script to automatically create state-based shapefiles using ogr2ogr

# Grab the name of the output shapefile
shapefilename=$1

# Move to arg2
shift

# Now grab the name of the initial input file
firstfile=$1

# Move past the first input file
shift

# make the initial state file
echo "Creating shapefile $shapefilename"
ogr2ogr $shapefilename $firstfile

# Grab the basename of the firstfiles
firstfilebase=`basename $firstfile .shp`

# Grab the basename of the shapefile for ogr2ogr update
shapefilenamebase=`basename $shapefilename .shp`

# Now make the rest of the state shape files
echo "Merging the rest of the files into the main shapefile"

while [[ $# > 0 ]]; do
  nextshpfile=$1
  echo "Now adding SHP file $nextshpfile"
  ogr2ogr -update -append $shapefilename $nextshpfile -nln $shapefilenamebase
  shift
done

echo "Processing finished"


