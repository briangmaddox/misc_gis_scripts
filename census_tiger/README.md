These are the scripts I use when I load US Census Tiger data into my local PostGIS database.

makecensustiger.sh is the main script.  You can keep them in their directory and then run them with the fully qualified path.
IE /home/bob/src/misc_gis_scripts/census_tiger/makecensustiger.sh.  It will now automatically download the required files
for you and then run the scripts to populate your database.  Edit makecensustiger.sh with your DB location and credentials.
