/*
Calendar functions
Source: https://gist.github.com/johngrimes/408559
Adapted from Tom Cunningham's 'Data Warehousing with MySql' (www.meansandends.com/mysql-data-warehouse)

Adapted from PostgreSQL query: https://duffn.medium.com/creating-a-date-dimension-table-in-postgresql-af3f8e2941ac
Queries for holiday flag adapted from: https://www.brianshowalter.com/blog/calendar_tables

*/

USE covid;

TRUNCATE TABLE numbers_small;
INSERT INTO numbers_small VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

TRUNCATE TABLE numbers;
INSERT INTO numbers
SELECT thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number
  FROM numbers_small thousands, numbers_small hundreds, numbers_small tens, numbers_small ones
LIMIT 1000000;
TRUNCATE TABLE `date`;
INSERT INTO `date` (
	date_id,
	date,
	timestamp,
	day_suffix,
	day_name,
	day_of_week,
	day_of_month,
	day_of_year,
	week_of_year,
	month,
	month_name,
	month_name_abbrev,
	quarter,
	year,
	first_day_of_week,
	last_day_of_week,
	first_day_of_month,
	last_day_of_month,
	first_day_of_year,
	last_day_of_year,
	yyyyww,
	yyyymm,
	weekend_flag
)
SELECT
	CAST(DATE_FORMAT(datum, " %Y%m%d") AS UNSIGNED) AS date_id,
	datum AS date,
	UNIX_TIMESTAMP(datum) AS timestamp,
	DATE_FORMAT(datum, '%D') AS day_suffix,
	DAYNAME(datum) AS day_name,
	DAYOFWEEK(datum) AS day_of_week,
	DAYOFMONTH(datum) AS day_of_month,
	DAYOFYEAR(datum) AS day_of_year,
	WEEKOFYEAR(datum) week_of_year,
	MONTH(datum) AS month,
	MONTHNAME(datum) AS month_name,
	DATE_FORMAT(datum, "%V") AS month_name_abbrev,
	EXTRACT(QUARTER FROM datum) AS quarter,
	YEAR(datum) AS year,
    DATE(datum - INTERVAL (DAYOFWEEK(datum)) DAY) AS first_day_of_week,
    DATE(datum + INTERVAL (7 - DAYOFWEEK(datum)) DAY) AS last_day_of_week,
	datum + (1 - DAYOFMONTH(datum)) AS first_day_of_month,
    LAST_DAY(datum) AS last_day_of_month,
    DATE_FORMAT(datum, '%Y-01-01') first_day_of_year,
    DATE_FORMAT(datum, '%Y-12-31') last_day_of_year,
    CAST(YEARWEEK(datum) AS UNSIGNED) AS yyyyww,
	CAST(DATE_FORMAT(datum, " %Y%m") AS UNSIGNED) AS yyyymm,
	CASE
	   WHEN DAYOFWEEK(datum) IN (1, 7) THEN TRUE
	   ELSE FALSE
	   END AS weekend_flag
FROM (
	SELECT
		number AS date_id,
		DATE_ADD('2015-01-01', INTERVAL number DAY) AS datum
	FROM numbers
	WHERE DATE_ADD('2015-01-01', INTERVAL number DAY) BETWEEN '2015-01-01' AND '2025-01-01'
	ORDER BY number
) AS t;


-- Set New Year's Day; handle cases when it lands on a weekend.
UPDATE `date`
	SET holiday_flag = 1,
		holiday_name = "New Year's Day"
	WHERE month = 1 AND day_of_month = 1;

UPDATE `date` d1
LEFT JOIN `date` d2 ON d2.date = d1.date + INTERVAL 1 DAY
SET d1.holiday_flag = 1, d1.holiday_name = "New Year's Day"
WHERE d1.day_of_week = 6 AND d2.month = 1 AND d2.day_of_week = 7 AND d2.holiday_flag = 1;

UPDATE `date` d1
LEFT JOIN `date` d2 ON d2.date = d1.date - INTERVAL 1 DAY
SET d1.holiday_flag = 1, d1.holiday_name = "New Year's Day"
WHERE d1.day_of_week = 2 AND d2.month = 1 AND d2.day_of_week = 1 AND d2.holiday_flag = 1;

-- MLK Day
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Martin Luther King Day'
WHERE month = 1 AND day_of_week = 2 AND day_of_month BETWEEN 15 AND 21;

-- President's Day
UPDATE `date`
SET holiday_flag = 1, holiday_name = "President's Day"
WHERE month = 2 AND day_of_week = 2 AND day_of_month BETWEEN 15 AND 21;

-- Memorial Day Day
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Memorial Day'
WHERE month = 5 AND day_of_week = 2 AND day_of_month BETWEEN 25 AND 21;

-- Independence Day
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Independence Day'
WHERE month = 6 AND day_of_month = 4 AND day_of_month;

UPDATE `date` d1
LEFT JOIN `date` d2 ON d2.date = d1.date + INTERVAL 1 DAY
SET d1.holiday_flag = 1, d1.holiday_name = "Independence Day"
WHERE d1.day_of_week = 6 AND d2.month = 7 AND d2.day_of_month = 4 AND d2.day_of_week = 7 AND d2.holiday_flag = 1;

UPDATE `date` d1
LEFT JOIN `date` d2 ON d2.date = d1.date - INTERVAL 1 DAY
SET d1.holiday_flag = 1, d1.holiday_name = "Independence Day"
WHERE d1.day_of_week = 2 AND d2.month = 7 AND d2.day_of_month = 4 AND d2.day_of_week = 1 AND d2.holiday_flag = 1;

-- Labor Day
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Independence Day'
WHERE month = 9 AND day_of_week = 2 AND day_of_month BETWEEN 1 AND 7;

-- Columbus Day
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Columbus Day'
WHERE month = 10 AND day_of_week = 3 AND day_of_month BETWEEN 1 AND 7;

-- Veteran's Day; handle case when it falls on a weekend
UPDATE `date`
SET holiday_flag = 1, holiday_name = "Veteran's Day"
WHERE month = 11 AND day_of_month = 11;

UPDATE `date` d1
LEFT JOIN `date` d2 ON d2.date = d1.date + INTERVAL 1 DAY
SET d1.holiday_flag = 1, d1.holiday_name = "Veteran's Day"
WHERE d1.day_of_week = 6 AND d2.month = 11 AND d2.day_of_month = 11 AND d2.day_of_week = 7 AND d2.holiday_flag = 1;

UPDATE `date` d1
LEFT JOIN `date` d2 ON d2.date = d1.date - INTERVAL 1 DAY
SET d1.holiday_flag = 1, d1.holiday_name = "Veteran's Day"
WHERE d1.day_of_week = 2 AND d2.month = 11 AND d2.day_of_month = 11 AND d2.day_of_week = 1 AND d2.holiday_flag = 1;

-- Thanksgiving Day, fourth Thursday in November
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Thanksgiving Day'
WHERE month = 11 AND day_of_week = 5 AND day_of_month BETWEEN 22 AND 28;

-- Black Friday
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Black Friday'
WHERE month = 11 AND day_of_week = 6 AND day_of_month BETWEEN 21 AND 29;

-- Christmas; handle case when it falls on a weekend
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Christmas Day'
WHERE month = 12 AND day_of_month = 25;

UPDATE `date` d1
LEFT JOIN `date` d2 ON d2.date = d1.date + INTERVAL 1 DAY
SET d1.holiday_flag = 1, d1.holiday_name = "Christmas Day"
WHERE d1.day_of_week = 6 AND d2.month = 12 AND d2.day_of_month = 25 AND d2.day_of_week = 7 AND d2.holiday_flag = 1;

UPDATE `date` d1
LEFT JOIN `date` d2 ON d2.date = d1.date - INTERVAL 1 DAY
SET d1.holiday_flag = 1, d1.holiday_name = "Christmas Day"
WHERE d1.day_of_week = 2 AND d2.month = 12 AND d2.day_of_month = 25 AND d2.day_of_week = 1 AND d2.holiday_flag = 1;

-- Easter
-- Credits: https://gist.github.com/drtomasso/e291633b5147d0be35e7
UPDATE `date`
SET holiday_flag = 1, holiday_name = 'Easter Sunday'
WHERE DAY(EasterSunday(YEAR(date))) = CAST(DAY(date) AS UNSIGNED)
	AND MONTH(EasterSunday(YEAR(date))) = CAST(MONTH(date) AS UNSIGNED)
;