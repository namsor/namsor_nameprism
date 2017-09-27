-- SQL companion file (Postgresql)
-- create a table with the results from NamePrism 'Nationality' http://www.name-prism.com/

DROP TABLE orig_best;

CREATE TABLE orig_best (
somedate varchar(1000),
firstname varchar(1000),
lastname varchar(1000),
onomabest varchar(1000),
onomabest_proba float,
onomabest1 varchar(1000),
onomabest2 varchar(1000),
onomabest3 varchar(1000),
onomabest4 varchar(1000),
onomabest5 varchar(1000),
onomaalt varchar(1000),
onomaalt_proba float,
onomaalt1 varchar(1000),
onomaalt2 varchar(1000),
onomaalt3 varchar(1000),
onomaalt4 varchar(1000),
onomaalt5 varchar(1000),
ignored varchar(1000)
);
 
COPY  orig_best FROM 'F:\projects\namsor\NamePrism\data\orig_best.txt' WITH DELIMITER '|'  NULL AS '';

CREATE INDEX orig_best_idx ON orig_best (firstname, lastname);

-- get the list of all names in the sample

COPY (
SELECT DISTINCT firstname, lastname
  FROM orig_best 
)
TO 'F:\projects\namsor\NamePrism\data\distinct_nameprism_fnln.txt' DELIMITER '|' ENCODING 'UTF8';

-- process the same data with NamSor 'Origin' API http://api.namsor.com/

CREATE TABLE namsor_origin (
firstName varchar(1000),
lastName varchar(1000),
country varchar(1000),
countryAlt varchar(1000),
score float,
script varchar(1000),
countryFirstName varchar(1000),
countryLastName varchar(1000),
scoreFirstName float,
scoreLastName float
);

COPY namsor_origin
FROM 'F:\projects\namsor\NamePrism\data\distinct_nameprism_fnln.txt.COUNTRY_SCRIPT.namsor' CSV HEADER DELIMITER '|' ENCODING 'UTF8';

CREATE INDEX namsor_origin_idx ON namsor_origin (firstname, lastname);

DROP TABLE country_region;

CREATE TABLE country_region (
countryName varchar(1000),
countryNumCode varchar(1000),
countryISO2 varchar(1000),
countryISO3 varchar(1000),
countryFIPS varchar(1000),
subregion varchar(1000),
region varchar(1000),
topregion varchar(1000)
);

COPY country_region
FROM 'F:/projects/namsor/NamSorCore/country_region.txt'  DELIMITER '|' ENCODING 'UTF8';

-- join and dump the results for comparison between Name-Prism 'Nationality' and NamSor 'Origin'
-- NB/ this file is not made public as NamSor License doesn't allow to make the raw output public

COPY (
SELECT 
	np.firstname, np.lastname, 
			np.onomabest, np.onomabest_proba, np.onomabest1, np.onomabest2, np.onomabest3, np.onomaalt, np.onomaalt_proba, np.onomaalt1, np.onomaalt2, np.onomaalt3,
	nm.country, nm.countryalt, nm.score, nm.script, nm.countryfirstname, nm.countrylastname, nm.scorefirstname, nm.scorelastname,
			r.countryname, r.countryiso2, r.subregion, r.region, r.topregion
	FROM namsor_origin nm, orig_best np, country_region r
  WHERE lower(np.firstName) = lower(nm.firstName) AND lower(np.lastname) = lower(nm.lastName) AND r.countryISO2 = nm.country
)
TO 'F:\projects\namsor\NamePrism\data\nameprism_vs_namsor_origin2.csv' CSV HEADER  DELIMITER ',' ENCODING 'UTF8';

-- join and dump the results for statistical comparison between Name-Prism 'Nationality' and NamSor 'Origin'
COPY (
	SELECT 
				np.onomabest, avg(np.onomabest_proba), np.onomabest1, np.onomabest2, np.onomabest3, np.onomaalt, np.onomaalt1, np.onomaalt2, np.onomaalt3,
		nm.country, nm.countryalt, avg(nm.score), nm.script, nm.countryfirstname, nm.countrylastname, nm.scorefirstname, nm.scorelastname,
				r.countryname, r.countryiso2, r.subregion, r.region, r.topregion, COUNT(*)
		FROM namsor_origin nm, orig_best np, country_region r
		
	  WHERE lower(np.firstName) = lower(nm.firstName) AND lower(np.lastname) = lower(nm.lastName) AND r.countryISO2 = nm.country
	  GROUP BY 
			np.onomabest, np.onomabest1, np.onomabest2, np.onomabest3, np.onomaalt, np.onomaalt1, np.onomaalt2, np.onomaalt3,
		nm.country, nm.countryalt, nm.script, nm.countryfirstname, nm.countrylastname, nm.scorefirstname, nm.scorelastname,
				r.countryname, r.countryiso2, r.subregion, r.region, r.topregion
)
TO 'F:\projects\namsor\NamePrism\data\nameprism_vs_namsor_origin_stats.csv' CSV HEADER  DELIMITER ',' ENCODING 'UTF8';

-- create a table with the results from NamePrism 'Ethnicity' http://www.name-prism.com/

DROP TABLE ethno_best;

CREATE TABLE ethno_best (
somedate varchar(1000),
firstname varchar(1000),
lastname varchar(1000),
onomabest varchar(1000),
onomabest_proba float,
onomabest1 varchar(1000),
onomabest2 varchar(1000),
onomabest3 varchar(1000),
onomabest4 varchar(1000),
onomabest5 varchar(1000),
onomaalt varchar(1000),
onomaalt_proba float,
onomaalt1 varchar(1000),
onomaalt2 varchar(1000),
onomaalt3 varchar(1000),
onomaalt4 varchar(1000),
onomaalt5 varchar(1000),
ignored varchar(1000)
);
 
COPY  ethno_best FROM 'F:\projects\namsor\NamePrism\data\ethno_best.txt' WITH DELIMITER '|'  NULL AS '';

CREATE INDEX ethno_best_idx ON ethno_best (firstname, lastname);

-- process the same data with NamSor 'Diaspora' API http://api.namsor.com/

CREATE TABLE namsor_diaspora (
firstName varchar(1000),
lastName varchar(1000),
countryHint varchar(1000),
country varchar(1000),
countryAlt varchar(1000),
ethno varchar(1000),
ethnoAlt varchar(1000),
score float,
script varchar(1000)
);

COPY namsor_diaspora
FROM 'F:\projects\namsor\NamePrism\data\distinct_nameprism_fnln.txt.ETHNO_COUNTRY_SCRIPT.namsor' CSV HEADER DELIMITER '|' ENCODING 'UTF8';

CREATE INDEX namsor_diaspora_idx ON namsor_diaspora (firstname, lastname);

-- join and dump the results for comparison between Name-Prism 'Ethnicity' and NamSor 'Diaspora'
-- NB/ this file is not made public as NamSor License doesn't allow to make the raw output public

COPY (
SELECT 
	np.firstname, np.lastname, 
			np.onomabest, np.onomabest_proba, np.onomabest1, np.onomabest2, np.onomabest3, np.onomaalt, np.onomaalt_proba, np.onomaalt1, np.onomaalt2, np.onomaalt3,
	nm.country, nm.countryalt, nm.ethno, nm.ethnoalt, nm.score, nm.script, 
			r.countryname, r.countryiso2, r.subregion, r.region, r.topregion
	FROM namsor_diaspora nm, ethno_best np, country_region r
  WHERE lower(np.firstName) = lower(nm.firstName) AND lower(np.lastname) = lower(nm.lastName) AND r.countryISO2 = nm.country
)
TO 'F:\projects\namsor\NamePrism\data\nameprism_vs_namsor_diaspora.csv' CSV HEADER  DELIMITER ',' ENCODING 'UTF8';

-- join and dump the results for statistical comparison between Name-Prism 'Ethnicity' and NamSor 'Diaspora'
COPY (
	SELECT 
				np.onomabest, avg(np.onomabest_proba), np.onomabest1, np.onomabest2, np.onomabest3, np.onomaalt, np.onomaalt1, np.onomaalt2, np.onomaalt3,
		nm.country, nm.countryalt, nm.ethno, nm.ethnoalt, avg(nm.score), nm.script, 
			r.countryname, r.countryiso2, r.subregion, r.region, r.topregion, COUNT(*)
		FROM namsor_diaspora nm, ethno_best np, country_region r
		
	  WHERE lower(np.firstName) = lower(nm.firstName) AND lower(np.lastname) = lower(nm.lastName) AND r.countryISO2 = nm.country
	  GROUP BY 
			np.onomabest, np.onomabest1, np.onomabest2, np.onomabest3, np.onomaalt, np.onomaalt1, np.onomaalt2, np.onomaalt3,
		nm.country, nm.countryalt, nm.ethno, nm.ethnoalt, nm.score, nm.script,
				r.countryname, r.countryiso2, r.subregion, r.region, r.topregion
)
TO 'F:\projects\namsor\NamePrism\data\nameprism_vs_namsor_diaspora_stats.csv' CSV HEADER  DELIMITER ',' ENCODING 'UTF8';
