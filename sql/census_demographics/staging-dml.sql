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
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DEPA_FinalProject_Demographics_ImportMe_2021-05-23.csv'
INTO TABLE `covid`.`county_demographics`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
