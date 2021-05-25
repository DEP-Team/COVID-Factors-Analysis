/*
Calendar functions
Source: https://gist.github.com/johngrimes/408559
Adapted from Tom Cunningham's 'Data Warehousing with MySql' (www.meansandends.com/mysql-data-warehouse)

Adapted from PostgreSQL query: https://duffn.medium.com/creating-a-date-dimension-table-in-postgresql-af3f8e2941ac

*/

CREATE DATABASE IF NOT EXISTS `covid`;
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
	holiday_name VARCHAR(50) NULL,
	holiday_flag BOOLEAN NOT NULL DEFAULT 0,
	weekend_flag BOOLEAN NOT NULL DEFAULT 0,
    PRIMARY KEY (`date_id`),
	UNIQUE KEY `date` (`date`),
	KEY `date_year_week` (`year`,`week_of_year`),
	INDEX `date_date_id_idx` (`date_id`),
	INDEX `date_date_idx` (`date`)
);

/**
 * Credits: https://gist.github.com/drtomasso/e291633b5147d0be35e7
 */
DROP FUNCTION IF EXISTS EasterSunday;

DELIMITER //
CREATE FUNCTION EasterSunday(inYear YEAR) RETURNS DATE DETERMINISTIC
BEGIN
    DECLARE a, b, c, d, e, f, g, h, i, k, l, m, n, p INT;

    DECLARE es DATE;

    SET a = MOD(inYear, 19);
    SET b = FLOOR(inYear / 100);
    SET c = MOD(inYear, 100);
    SET d = FLOOR(b / 4);
    SET e = MOD(b, 4);
    SET f = FLOOR((b + 8) / 25);
    SET g = FLOOR((b - f + 1) / 3);
    SET h = MOD((19 * a + b - d - g + 15), 30);
    SET i = FLOOR(c / 4);
    SET k = MOD(c, 4);
    SET l = MOD((32 + 2 * e + 2 * i - h - k), 7);
    SET m = FLOOR((a + 11 * h + 22 * l) / 451);
    SET n = FLOOR((h + l - 7 * m + 114) / 31);
    SET p = MOD((h + l - 7 * m + 114), 31) + 1;

    SET es = CONCAT_WS('-', inYear, n, p);

    RETURN es;
END
//
DELIMITER ;
