/*
Calendar functions
Source: https://gist.github.com/johngrimes/408559
Adapted from Tom Cunningham's 'Data Warehousing with MySql' (www.meansandends.com/mysql-data-warehouse)

Adapted from PostgreSQL query: https://duffn.medium.com/creating-a-date-dimension-table-in-postgresql-af3f8e2941ac

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
	DATE_FORMAT(datum, "%d") AS month_name_abbrev,
	EXTRACT(QUARTER FROM datum) AS quarter,
	YEAR(datum) AS year,
    DATE(datum + INTERVAL (DAYOFWEEK(datum)) DAY) AS first_day_of_week,
    DATE(datum + INTERVAL (7 - DAYOFWEEK(datum)) DAY) AS last_day_of_week,
	datum + (1 - DAYOFMONTH(datum)) AS first_day_of_month,
    LAST_DAY(datum) AS last_day_of_month,
    DATE_FORMAT(datum, '%Y-12-31') first_day_of_year,
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
