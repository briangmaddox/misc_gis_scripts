These are the scripts I use when I load US Census Tiger data into my local PostGIS database.

makecensustiger.sh is the main script.  Put them somewhere in your path or edit the scripts to put the locations of the other ones.  The scripts are written to expect the following directory structure:

bmaddox@tinker:/mnt/filestore/temp/gis$ ls -l
total 164
drwxr-xr-x+  2 bmaddox bmaddox      0 Feb 25 15:13 AIANNH
drwxr-xr-x+  2 bmaddox bmaddox      0 Feb 25 15:13 ANRC
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 25 15:16 AREALM
drwxr-xr-x+ 58 bmaddox bmaddox      0 Feb 25 16:29 AREAWATER
drwxr-xr-x+  4 bmaddox bmaddox      0 Feb 25 17:20 BG
drwxr-xr-x+  2 bmaddox bmaddox      0 Feb 25 17:21 CD
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 25 17:21 CONCITY
drwxr-xr-x+  2 bmaddox bmaddox      0 Feb 26 05:41 COUNTY
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 25 17:30 COUSUB
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 25 17:30 ELSD
drwxr-xr-x+ 58 bmaddox bmaddox      0 Feb 25 19:59 LINEARWATER
drwxr-xr-x+  2 bmaddox bmaddox      0 Feb 25 21:16 MIL
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 25 21:20 PLACE
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 25 21:30 POINTLM
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 25 21:40 PRISECROADS
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 25 21:42 PUMA
drwxr-xr-x+  2 bmaddox bmaddox      0 Feb 25 21:44 RAILS
drwxr-xr-x+ 58 bmaddox bmaddox      0 Feb 26 02:49 ROADS
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 26 05:11 SCSD
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 26 05:15 SLDL
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 26 05:17 SLDU
drwxr-xr-x+  2 bmaddox bmaddox      0 Feb 26 05:41 STATE
drwxr-xr-x+  3 bmaddox bmaddox      0 Feb 26 05:21 UNSD
drwxr-xr-x+  2 bmaddox bmaddox      0 Feb 26 05:39 ZCTA5
bmaddox@tinker:/mnt/filestore/temp/gis$ 

