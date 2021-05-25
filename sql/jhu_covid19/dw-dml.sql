USE covid_dw;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- This query tends to time out.
# SET GLOBAL connect_timeout=28800;
# SET GLOBAL interactive_timeout=28800;
# SET GLOBAL wait_timeout=28800;
# SET SQL_SAFE_UPDATES = 0;

INSERT INTO `county_cases_daily` (
	county_key,
    date_key,
    county_date_id,
    cases_new,
    deaths_new,
    cases_total,
    deaths_total,
    cases_new_per_100k,
    deaths_new_per_100k,
    case_rate,
    death_rate,
    case_rate_per_100k,
    death_rate_per_100k
) SELECT
		dim_county.county_key,
        cc.date_id,
        cc.county_date_id,
        cc.new_cases as cases_new,
        cc.new_deaths as deaths_new,
        cc.total_cases as cases_total,
        cc.total_deaths as deaths_total,
		cc.new_cases / cd.tot_population * 100000 as cases_new_per_100k,
        cc.new_deaths / cd.tot_population * 100000 as deaths_new_per_100k,
        cc.total_cases / cd.tot_population * 100000 as cases_total_per_100k,
        cc.total_deaths / cd.tot_population * 100000 as deaths_total_per_100k,
        AVG(new_cases) OVER(PARTITION BY cc.county_id ORDER BY date_id
								ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
			AS case_rate,
		AVG(new_deaths) OVER(PARTITION BY cc.county_id ORDER BY date_id
								ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
			AS death_rate
	FROM
		covid.county_cases AS cc
        JOIN dim_county
			USING (county_id)
		JOIN county_demographics cd
			USING (county_key)
;

-- clean up cases where ma7d and ma14d are negative
UPDATE `county_cases_daily` SET case_rate = 0 WHERE case_rate < 0;
UPDATE `county_cases_daily` SET death_rate = 0 WHERE death_rate < 0;

UPDATE `county_cases_daily`
JOIN county_demographics USING (county_key)
SET case_rate_per_100k = case_rate / tot_population * 100000,
	death_rate_per_100k = death_rate / tot_population * 100000;


--
-- state-level aggregation
--

/*
INSERT INTO `state_cases_daily` (
	state_key,
    date_key,
    county_date_id,
    cases_new,
    deaths_new,
    cases_total,
    deaths_total,
    cases_new_per_100k,
    deaths_new_per_100k,
    case_rate,
    death_rate,
    case_rate_per_100k,
    death_rate_per_100k
) SELECT
		state_key,
        date_key,
        cc.new_cases as cases_new,
        cc.new_deaths as deaths_new,
        cc.total_cases as cases_total,
        cc.total_deaths as deaths_total,
		cc.new_cases / cd.tot_population * 100000 as cases_new_per_100k,
        cc.new_deaths / cd.tot_population * 100000 as deaths_new_per_100k,
        cc.total_cases / cd.tot_population * 100000 as cases_total_per_100k,
        cc.total_deaths / cd.tot_population * 100000 as deaths_total_per_100k,
        AVG(new_cases) OVER(PARTITION BY cc.state_key ORDER BY date_id
								ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
			AS case_rate,
		AVG(new_deaths) OVER(PARTITION BY cc.state_key ORDER BY date_id
								ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
			AS death_rate
	FROM (
		SELECT
    		dim_county.state_key,
			cc.date_id AS date_key,
			SUM(cc.new_cases) AS new_cases,
			SUM(cc.new_deaths) AS new_deaths,
			SUM(cc.positives_total) AS positives_total,
			SUM(cc.deaths_total) AS deaths_total
		FROM covid.county_cases AS cc
        JOIN dim_county
			USING (county_id)
		GROUP BY
			state_key,
            date_key
	) AS cc
	JOIN county_demographic AS cd
		USING (county_key)
;

*/