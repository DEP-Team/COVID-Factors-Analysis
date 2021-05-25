USE covid_dw;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


TRUNCATE TABLE `dim_date`;
INSERT INTO `dim_date` (
	date_key,
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
	holiday_name,
	holiday_flag,
	weekend_flag
)
SELECT
	date_id AS date_key,
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
	holiday_name,
	holiday_flag,
	weekend_flag
FROM covid.`date`;