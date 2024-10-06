CREATE TABLE "geoname" (
geonameid BIGINT,
name VARCHAR(200),
asciiname VARCHAR(200),
alternatenames TEXT,
latitude FLOAT,
longitude FLOAT,
fclass CHAR(1),
fcode VARCHAR(10),
country VARCHAR(2),
cc2 VARCHAR(200),
admin1 VARCHAR(20),
admin2 VARCHAR(80),
admin3 VARCHAR(20),
admin4 VARCHAR(20),
population BIGINT,
elevation INTEGER,
dem INTEGER,
timezone VARCHAR(40),
moddate date
);

CREATE TABLE "alternatename" (
alternatenameid BIGINT,
geonameid BIGINT,
isolanguage VARCHAR(7),
alternatename VARCHAR(400),
ispreferredname BOOLEAN,
isshortname BOOLEAN,
iscolloquial BOOLEAN,
ishistoric BOOLEAN
);


CREATE TABLE "isolanguage" (
 iso639_3 CHAR(3),
 iso639_2 CHAR(10),
 iso639_1 CHAR(3),
 languagename VARCHAR(100)
);

CREATE TABLE "countryinfo" ( 
 isoalpha2 CHAR(2),
 isoalpha3 CHAR(3),
 isonumeric INTEGER,
 fipscode VARCHAR(3),
 name VARCHAR(200),
 capital VARCHAR(200),
 areainsqkm DOUBLE PRECISION,
 population INTEGER,
 continent VARCHAR(2),
 tld VARCHAR(10),
 currencycode VARCHAR(3),
 currencyname VARCHAR(20),
 phone VARCHAR(20),
 postalcode VARCHAR(100),
 postalcoderegex VARCHAR(200),
 languages VARCHAR(200),
 geonameid INTEGER,
 neighbors VARCHAR(50),
 equivfipscode VARCHAR(3)
);

CREATE TABLE "timezones" (
countrycode CHAR(2),
timezoneid VARCHAR(30),
gmtoffset DOUBLE PRECISION,
dstoffset DOUBLE PRECISION,
rawoffset DOUBLE PRECISION
);


CREATE TABLE "admin1codesascii" ( 
code CHAR(15), 
name TEXT, 
nameascii TEXT, 
geonameid BIGINT 
); 


CREATE TABLE "admin2codes" (
 code VARCHAR(30),
 namelocal TEXT,
 name TEXT,
 geonameid BIGINT
);


CREATE TABLE "featurecodes" ( 
code VARCHAR(10), 
name VARCHAR(200), 
description TEXT 
); 


CREATE TABLE "usertags" (
geonameid BIGINT,
tag VARCHAR(40)
);


CREATE TABLE "hierarchy" (
parentid BIGINT,
childid BIGINT,
type VARCHAR(40)
);

CREATE TABLE "admincode5" (
geonameid BIGINT,
admcode5 TEXT
);
