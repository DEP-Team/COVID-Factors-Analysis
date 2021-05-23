#------------------------------
# Whitney Schreiber
# Data Engineering Platforms Spring 2021
# Final Project (Covid-19)
# County Level Demographics - DDL & DML
# Date: 05-23-21
#------------------------------

CREATE SCHEMA IF NOT EXISTS `covid` DEFAULT CHARACTER SET utf8mb4 ;
USE `covid` ;

# Create demographics table
CREATE TABLE IF NOT EXISTS `covid`.`county_demographics` (
						  `county_id` varchar(5) NOT NULL,
                          `tot_population` int NULL DEFAULT NULL,
                          `pop_density` float NULL DEFAULT NULL,
                          `median_age` int NULL DEFAULT NULL,
                          `tot_pop_18plus` int NULL DEFAULT NULL,
                          `tot_pop_65plus` int NULL DEFAULT NULL,
                          `tot_pop_65_74yrs` int NULL DEFAULT NULL,
                          `tot_pop_75_84yrs` int NULL DEFAULT NULL,
                          `tot_pop_85plus` int NULL DEFAULT NULL,
                          `pct_pop_18plus` float NULL DEFAULT NULL,
                          `pct_pop_65plus` float NULL DEFAULT NULL,
                          `pct_pop_65_74yrs` float NULL DEFAULT NULL,
                          `pct_pop_75_84yrs` float NULL DEFAULT NULL,
                          `pct_pop_85plus` float NULL DEFAULT NULL,
                          `tot_pop_male` int NULL DEFAULT NULL,
                          `tot_pop_male_0_9yrs` int NULL DEFAULT NULL,
                          `tot_pop_male_10_19yrs` int NULL DEFAULT NULL,
                          `tot_pop_male_20_29yrs` int NULL DEFAULT NULL,
                          `tot_pop_male_30_39yrs` int NULL DEFAULT NULL,
                          `tot_pop_male_40_49yrs` int NULL DEFAULT NULL,
                          `tot_pop_male_50_64yrs` int NULL DEFAULT NULL,
                          `pct_pop_male` float NULL DEFAULT NULL,
                          `pct_pop_male_0_9yrs` float NULL DEFAULT NULL,
                          `pct_pop_male_10_19yrs` float NULL DEFAULT NULL,
                          `pct_pop_male_20_29yrs` float NULL DEFAULT NULL,
                          `pct_pop_male_30_39yrs` float NULL DEFAULT NULL,
                          `pct_pop_male_40_49yrs` float NULL DEFAULT NULL,
                          `pct_pop_male_50_64yrs` float NULL DEFAULT NULL,
                          `tot_pop_female` int NULL DEFAULT NULL,
                          `tot_pop_female_0_9yrs` int NULL DEFAULT NULL,
                          `tot_pop_female_10_19yrs` int NULL DEFAULT NULL,
                          `tot_pop_female_20_29yrs` int NULL DEFAULT NULL,
                          `tot_pop_female_30_39yrs` int NULL DEFAULT NULL,
                          `tot_pop_female_40_49yrs` int NULL DEFAULT NULL,
                          `tot_pop_female_50_64yrs` int NULL DEFAULT NULL,
                          `pct_pop_female` float NULL DEFAULT NULL,
                          `pct_pop_female_0_9yrs` float NULL DEFAULT NULL,
                          `pct_pop_female_10_19yrs` float NULL DEFAULT NULL,
                          `pct_pop_female_20_29yrs` float NULL DEFAULT NULL,
                          `pct_pop_female_30_39yrs` float NULL DEFAULT NULL,
                          `pct_pop_female_40_49yrs` float NULL DEFAULT NULL,
                          `pct_pop_female_50_64yrs` float NULL DEFAULT NULL,
                          `tot_pop_white_alone` int NULL DEFAULT NULL,
                          `tot_pop_black_alone` int NULL DEFAULT NULL,
                          `tot_pop_american_indian_alaskan_alone` int NULL DEFAULT NULL,
                          `tot_pop_asian_alone` int NULL DEFAULT NULL,
                          `tot_pop_hawaiian_pacific_islander_alone` int NULL DEFAULT NULL,
                          `tot_pop_other_race_alone` int NULL DEFAULT NULL,
                          `tot_pop_two_or_more_races` int NULL DEFAULT NULL,
                          `tot_pop_not_hisp` int NULL DEFAULT NULL,
                          `tot_pop_hisp` int NULL DEFAULT NULL,
                          `pct_pop_white_alone` float NULL DEFAULT NULL,
                          `pct_pop_black_alone` float NULL DEFAULT NULL,
                          `pct_pop_american_indian_alaskan_alone` float NULL DEFAULT NULL,
                          `pct_pop_asian_alone` float NULL DEFAULT NULL,
                          `pct_pop_hawaiian_pacific_islander_alone` float NULL DEFAULT NULL,
                          `pct_pop_other_race_alone` float NULL DEFAULT NULL,
                          `pct_pop_two_or_more_races` float NULL DEFAULT NULL,
                          `pct_pop_hisp` float NULL DEFAULT NULL,
                          `pct_pop_not_hisp` float NULL DEFAULT NULL,
                          `tot_pop_wfh` int NULL DEFAULT NULL,
                          `pct_pop_wfh` float NULL DEFAULT NULL,
                          `avg_hh_size` int NULL DEFAULT NULL,
                          `tot_hh_65plus` int NULL DEFAULT NULL,
                          `pct_hh_65plus` float NULL DEFAULT NULL,
                          `tot_pop_65plus_group_quarters` int NULL DEFAULT NULL,
                          `pct_pop_65plus_group_quarters` float NULL DEFAULT NULL,
                          `tot_hh_below_poverty_level` int NULL DEFAULT NULL,
                          `tot_hh_above_poverty_level` int NULL DEFAULT NULL,
                          `pct_hh_below_poverty_level` float NULL DEFAULT NULL,
                          `pct_hh_above_poverty_level` float NULL DEFAULT NULL,
                          `pct_hh_receive_foodstamps` float NULL DEFAULT NULL,
                          `tot_hh_inc_lessthan_10000` int NULL DEFAULT NULL,
                          `tot_hh_inc_10000_14999` int NULL DEFAULT NULL,
                          `tot_hh_inc_15000_24999` int NULL DEFAULT NULL,
                          `tot_hh_inc_25000_34999` int NULL DEFAULT NULL,
                          `tot_hh_inc_35000_49999` int NULL DEFAULT NULL,
                          `tot_hh_inc_50000_74999` int NULL DEFAULT NULL,
                          `tot_hh_inc_lessthan_75000` int NULL DEFAULT NULL,
                          `tot_hh_inc_75000_99999` int NULL DEFAULT NULL,
                          `pct_hh_inc_lessthan_10000` float NULL DEFAULT NULL,
                          `pct_hh_inc_10000_14999` float NULL DEFAULT NULL,
                          `pct_hh_inc_15000_24999` float NULL DEFAULT NULL,
                          `pct_hh_inc_25000_34999` float NULL DEFAULT NULL,
                          `pct_hh_inc_35000_49999` float NULL DEFAULT NULL,
                          `pct_hh_inc_50000_74999` float NULL DEFAULT NULL,
                          `pct_hh_inc_lessthan_75000` float NULL DEFAULT NULL,
                          `pct_hh_inc_75000_99999` float NULL DEFAULT NULL,
                          PRIMARY KEY (`county_id`))
                          ENGINE InnoDB
                          DEFAULT CHARACTER SET utf8mb4;
                          

# turn of SQL safe mode
SET sql_mode = '';

# load data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DEPA_FinalProject_Demographics_ImportMe_2021-05-23.csv'
INTO TABLE `covid`.`county_demographics`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
                          