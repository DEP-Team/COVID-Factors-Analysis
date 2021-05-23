/*
Calendar functions
Source: https://gist.github.com/johngrimes/408559
Adapted from Tom Cunningham's 'Data Warehousing with MySql' (www.meansandends.com/mysql-data-warehouse)

Adapted from PostgreSQL query: https://duffn.medium.com/creating-a-date-dimension-table-in-postgresql-af3f8e2941ac

*/

USE covid;

CREATE TABLE IF NOT EXISTS `numbers_small` (
	number INT
);

CREATE TABLE IF NOT EXISTS `numbers` (
	number BIGINT
);

CREATE TABLE IF NOT EXISTS `date` (
	date_id INT NOT NULL,
	date DATE NOT NULL,
	timestamp  BIGINT NOT NULL,
	day_suffix VARCHAR(4) NOT NULL,
	day_name VARCHAR(9) NOT NULL,
	day_of_week INT NOT NULL,
	day_of_month INT NOT NULL,
	day_of_year INT NOT NULL,
	week_of_year INT NOT NULL,
	month INT NOT NULL,
	month_name VARCHAR(9) NOT NULL,
	month_name_abbrev CHAR(3) NOT NULL,
	quarter INT NOT NULL,
	year INT NOT NULL,
	first_day_of_week DATE NOT NULL,
	last_day_of_week DATE NOT NULL,
	first_day_of_month DATE NOT NULL,
	last_day_of_month DATE NOT NULL,
	first_day_of_year DATE NOT NULL,
	last_day_of_year DATE NOT NULL,
	yyyyww INT,
	yyyymm INT,
	holiday_name VARCHAR(20) NULL,
	holiday_flag BOOLEAN NOT NULL DEFAULT 0,
	weekend_flag BOOLEAN NOT NULL DEFAULT 0,
    PRIMARY KEY (`date_id`),
	UNIQUE KEY `date` (`date`),
	KEY `date_year_week` (`year`,`week_of_year`)
);
