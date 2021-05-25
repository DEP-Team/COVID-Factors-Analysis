#------------------------------
# Whitney Schreiber
# Data Engineering Platforms Spring 2021
# Final Project (Covid-19)
# County Level Demographics - DDL & DML
# Date: 05-23-21
#------------------------------

# turn of SQL safe mode
SET sql_mode = '';

# load data
LOAD DATA LOCAL INFILE 'data/import/county_demographics.csv'
INTO TABLE `county_demographics` FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;
