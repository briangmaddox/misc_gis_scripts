#!/bin/bash
shopt -s extglob
#set -x #echo on for debugging (comment to disable)

# Grab the name to append to the directories
DIREXTENSION=$1

# Have we run shp2pgsql yet
DONESHPTOPGSQL=false

echo "Making state directories."
mkdir 01_Alabama_$DIREXTENSION
mkdir 02_Alaska_$DIREXTENSION
mkdir 04_Arizona_$DIREXTENSION
mkdir 05_Arkansas_$DIREXTENSION
mkdir 06_California_$DIREXTENSION
mkdir 08_Colorado_$DIREXTENSION
mkdir 09_Connecticut_$DIREXTENSION
mkdir 10_Delaware_$DIREXTENSION
mkdir 11_District_of_Columbia_$DIREXTENSION
mkdir 12_Florida_$DIREXTENSION
mkdir 13_Georgia_$DIREXTENSION
mkdir 15_Hawaii_$DIREXTENSION
mkdir 16_Idaho_$DIREXTENSION
mkdir 17_Illinois_$DIREXTENSION
mkdir 18_Indiana_$DIREXTENSION
mkdir 19_Iowa_$DIREXTENSION
mkdir 20_Kansas_$DIREXTENSION
mkdir 21_Kentucky_$DIREXTENSION
mkdir 22_Louisiana_$DIREXTENSION
mkdir 23_Maine_$DIREXTENSION
mkdir 24_Maryland_$DIREXTENSION
mkdir 25_Massachusetts_$DIREXTENSION
mkdir 26_Michigan_$DIREXTENSION
mkdir 27_Minnesota_$DIREXTENSION
mkdir 28_Mississippi_$DIREXTENSION
mkdir 29_Missouri_$DIREXTENSION
mkdir 30_Montana_$DIREXTENSION
mkdir 31_Nebraska_$DIREXTENSION
mkdir 32_Nevada_$DIREXTENSION
mkdir 33_New_Hampshire_$DIREXTENSION
mkdir 34_New_Jersey_$DIREXTENSION
mkdir 35_New_Mexico_$DIREXTENSION
mkdir 36_New_York_$DIREXTENSION
mkdir 37_North_Carolina_$DIREXTENSION
mkdir 38_North_Dakota_$DIREXTENSION
mkdir 39_Ohio_$DIREXTENSION
mkdir 40_Oklahoma_$DIREXTENSION
mkdir 41_Oregon_$DIREXTENSION
mkdir 42_Pennsylvania_$DIREXTENSION
mkdir 44_Rhode_Island_$DIREXTENSION
mkdir 45_South_Carolina_$DIREXTENSION
mkdir 46_South_Dakota_$DIREXTENSION
mkdir 47_Tennessee_$DIREXTENSION
mkdir 48_Texas_$DIREXTENSION
mkdir 49_Utah_$DIREXTENSION
mkdir 50_Vermont_$DIREXTENSION
mkdir 51_Virginia_$DIREXTENSION
mkdir 53_Washington_$DIREXTENSION
mkdir 54_West_Virginia_$DIREXTENSION
mkdir 55_Wisconsin_$DIREXTENSION
mkdir 56_Wyoming_$DIREXTENSION
mkdir 60_American_Samoa_$DIREXTENSION
mkdir 64_Federated_States_of_Micronesia_$DIREXTENSION
mkdir 66_Guam_$DIREXTENSION
mkdir 68_Marshall_Islands_$DIREXTENSION
mkdir 69_Commonwealth_of_the_Northern_Mariana_Islands_$DIREXTENSION
mkdir 70_Palau_$DIREXTENSION
mkdir 72_Puerto_Rico_$DIREXTENSION
mkdir 74_US_Minor_Outlying_Islands_$DIREXTENSION
mkdir 78_US_Virgin_Islands_$DIREXTENSION

echo "Moving files to state directories"

mv tl_2023_01* 01_Alabama_$DIREXTENSION
mv tl_2023_02* 02_Alaska_$DIREXTENSION
mv tl_2023_04* 04_Arizona_$DIREXTENSION
mv tl_2023_05* 05_Arkansas_$DIREXTENSION
mv tl_2023_06* 06_California_$DIREXTENSION
mv tl_2023_08* 08_Colorado_$DIREXTENSION
mv tl_2023_09* 09_Connecticut_$DIREXTENSION
mv tl_2023_10* 10_Delaware_$DIREXTENSION
mv tl_2023_11* 11_District_of_Columbia_$DIREXTENSION
mv tl_2023_12* 12_Florida_$DIREXTENSION
mv tl_2023_13* 13_Georgia_$DIREXTENSION
mv tl_2023_15* 15_Hawaii_$DIREXTENSION
mv tl_2023_16* 16_Idaho_$DIREXTENSION
mv tl_2023_17* 17_Illinois_$DIREXTENSION
mv tl_2023_18* 18_Indiana_$DIREXTENSION
mv tl_2023_19* 19_Iowa_$DIREXTENSION
mv tl_2023_20* 20_Kansas_$DIREXTENSION
mv tl_2023_21* 21_Kentucky_$DIREXTENSION
mv tl_2023_22* 22_Louisiana_$DIREXTENSION
mv tl_2023_23* 23_Maine_$DIREXTENSION
mv tl_2023_24* 24_Maryland_$DIREXTENSION
mv tl_2023_25* 25_Massachusetts_$DIREXTENSION
mv tl_2023_26* 26_Michigan_$DIREXTENSION
mv tl_2023_27* 27_Minnesota_$DIREXTENSION
mv tl_2023_28* 28_Mississippi_$DIREXTENSION
mv tl_2023_29* 29_Missouri_$DIREXTENSION
mv tl_2023_30* 30_Montana_$DIREXTENSION
mv tl_2023_31* 31_Nebraska_$DIREXTENSION
mv tl_2023_32* 32_Nevada_$DIREXTENSION
mv tl_2023_33* 33_New_Hampshire_$DIREXTENSION
mv tl_2023_34* 34_New_Jersey_$DIREXTENSION
mv tl_2023_35* 35_New_Mexico_$DIREXTENSION
mv tl_2023_36* 36_New_York_$DIREXTENSION
mv tl_2023_37* 37_North_Carolina_$DIREXTENSION
mv tl_2023_38* 38_North_Dakota_$DIREXTENSION
mv tl_2023_39* 39_Ohio_$DIREXTENSION
mv tl_2023_40* 40_Oklahoma_$DIREXTENSION
mv tl_2023_41* 41_Oregon_$DIREXTENSION
mv tl_2023_42* 42_Pennsylvania_$DIREXTENSION
mv tl_2023_44* 44_Rhode_Island_$DIREXTENSION
mv tl_2023_45* 45_South_Carolina_$DIREXTENSION
mv tl_2023_46* 46_South_Dakota_$DIREXTENSION
mv tl_2023_47* 47_Tennessee_$DIREXTENSION
mv tl_2023_48* 48_Texas_$DIREXTENSION
mv tl_2023_49* 49_Utah_$DIREXTENSION
mv tl_2023_50* 50_Vermont_$DIREXTENSION
mv tl_2023_51* 51_Virginia_$DIREXTENSION
mv tl_2023_53* 53_Washington_$DIREXTENSION
mv tl_2023_54* 54_West_Virginia_$DIREXTENSION
mv tl_2023_55* 55_Wisconsin_$DIREXTENSION
mv tl_2023_56* 56_Wyoming_$DIREXTENSION
mv tl_2023_60* 60_American_Samoa_$DIREXTENSION
mv tl_2023_64* 64_Federated_States_of_Micronesia_$DIREXTENSION
mv tl_2023_66* 66_Guam_$DIREXTENSION
mv tl_2023_68* 68_Marshall_Islands_$DIREXTENSION
mv tl_2023_69* 69_Commonwealth_of_the_Northern_Mariana_Islands_$DIREXTENSION
mv tl_2023_70* 70_Palau_$DIREXTENSION
mv tl_2023_72* 72_Puerto_Rico_$DIREXTENSION
mv tl_2023_74* 74_US_Minor_Outlying_Islands_$DIREXTENSION
mv tl_2023_78* 78_US_Virgin_Islands_$DIREXTENSION

# Prune any empty directories
find . -type d -empty -exec rmdir {} \;

# Now iterate through the directories
for TDIR in ??_*/
do
    echo "Now processing directory $TDIR"
    cd $TDIR
    for foo in *.zip; do unzip -q $foo; done
    OUTPUTNAME=`basename $PWD`
    $DOOGR ${OUTPUTNAME}.shp tl*.shp
    echo "Removing temporary files"
    rm tl*.!(zip)
    echo "Moving worked files"
    mv tl*.zip ..
    if [ "$DONESHPTOPGSQL" = "true" ]
    then
        ${SHP2PGSQL} -s 4269 -a ??_*.shp $DIREXTENSION | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
    else
        ${SHP2PGSQL} -s 4269 -c -I ??_*.shp $DIREXTENSION | ${PSQL} --host=${DBHOST} --port=${DBPORT} --username=${DBUSER} --dbname=${TIGERDB}
        DONESHPTOPGSQL=true
    fi
    cd ..
done

echo "Finished adding files to database table $DIREXTENSION"
