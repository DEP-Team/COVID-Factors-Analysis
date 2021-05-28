USE covid_dw;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- This query tends to time out.
# SET GLOBAL connect_timeout=28800;
# SET GLOBAL interactive_timeout=28800;
# SET GLOBAL wait_timeout=28800;
SET SQL_SAFE_UPDATES = 0;

INSERT INTO `county_cases_daily` (
	county_key,
    date_key,
    cases_new,
    deaths_new,
    cases_total,
    deaths_total,
    cases_new_per_100k,
    deaths_new_per_100k,
    cases_total_per_100k,
    deaths_total_per_100k,
    case_rate,
    mortality_rate,
    case_rate_per_100k,
    mortality_rate_per_100k
)
	SELECT
		dim_county.county_key,
		date_id AS date_key,
		new_cases as cases_new,
		new_deaths as deaths_new,
		total_cases as cases_total,
		total_deaths as deaths_total,
		new_cases / tot_population * 100000 as cases_new_per_100k,
		new_deaths / tot_population * 100000 as deaths_new_per_100k,
		total_cases / tot_population * 100000 as cases_total_per_100k,
		total_deaths / tot_population * 100000 as deaths_total_per_100k,
		case_rate,
		mortality_rate,
		case_rate / tot_population * 100000 as case_rate_per_100k,
		mortality_rate / tot_population * 100000 as mortality_rate_per_100k
	FROM (
		SELECT
			cc.*,
			AVG(new_cases) OVER(PARTITION BY cc.county_id ORDER BY date_id
									ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING)
				AS case_rate,
			AVG(new_deaths) OVER(PARTITION BY cc.county_id ORDER BY date_id
									ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING)
				AS mortality_rate
		FROM
			covid.county_cases AS cc
	) AS t
	JOIN dim_county
		USING (county_id)
	JOIN county_demographics cd
		USING (county_key)
;

--
-- state-level aggregation
--

INSERT INTO `state_cases_daily` (
	state_key,
    date_key,
    cases_new,
    deaths_new,
    cases_total,
    deaths_total,
    cases_new_per_100k,
    deaths_new_per_100k,
    cases_total_per_100k,
    deaths_total_per_100k,
    case_rate,
    mortality_rate,
    case_rate_per_100k,
    mortality_rate_per_100k
) SELECT
	state_key,
	date_key,
	cases_new,
	deaths_new,
	cases_total,
	deaths_total,
	cases_new / tot_population * 100000 as cases_new_per_100k,
	deaths_new / tot_population * 100000 as deaths_new_per_100k,
	cases_total / tot_population * 100000 as cases_total_per_100k,
	deaths_total / tot_population * 100000 as deaths_total_per_100k,
    case_rate,
    mortality_rate,
	case_rate / tot_population * 100000 as case_rate_per_100k,
	mortality_rate / tot_population * 100000 as mortality_rate_per_100k
FROM (
	SELECT
		*,
        AVG(cases_new) OVER(PARTITION BY state_key ORDER BY date_key
								ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING)
			AS case_rate,
		AVG(deaths_new) OVER(PARTITION BY state_key ORDER BY date_key
								ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING)
			AS mortality_rate
	FROM (
		SELECT
    		dim_county.state_key,
			cc.date_key AS date_key,
			SUM(cc.cases_new) AS cases_new,
			SUM(cc.deaths_new) AS deaths_new,
			SUM(cc.cases_total) AS cases_total,
			SUM(cc.deaths_total) AS deaths_total,
			SUM(cd.tot_population) AS tot_population
		FROM county_cases_daily AS cc
		JOIN county_demographics AS cd
			USING (county_key)
        JOIN dim_county
			USING (county_key)
		GROUP BY
			state_key,
            date_key
	) AS t
) AS t
;

INSERT INTO `csa_cases_daily` (
	csa_key,
    date_key,
    cases_new,
    deaths_new,
    cases_total,
    deaths_total,
    cases_new_per_100k,
    deaths_new_per_100k,
    cases_total_per_100k,
    deaths_total_per_100k,
    case_rate,
    mortality_rate,
    case_rate_per_100k,
    mortality_rate_per_100k
) SELECT
	csa_key,
	date_key,
	cases_new,
	deaths_new,
	cases_total,
	deaths_total,
	cases_new / tot_population * 100000 as cases_new_per_100k,
	deaths_new / tot_population * 100000 as deaths_new_per_100k,
	cases_total / tot_population * 100000 as cases_total_per_100k,
	deaths_total / tot_population * 100000 as deaths_total_per_100k,
    case_rate,
    mortality_rate,
	case_rate / tot_population * 100000 as case_rate_per_100k,
	mortality_rate / tot_population * 100000 as mortality_rate_per_100k
FROM (
	SELECT
		*,
        AVG(cases_new) OVER(PARTITION BY csa_key ORDER BY date_key
								ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING)
			AS case_rate,
		AVG(deaths_new) OVER(PARTITION BY csa_key ORDER BY date_key
								ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING)
			AS mortality_rate
	FROM (
		SELECT
    		dim_county.csa_key,
			cc.date_key AS date_key,
			SUM(cc.cases_new) AS cases_new,
			SUM(cc.deaths_new) AS deaths_new,
			SUM(cc.cases_total) AS cases_total,
			SUM(cc.deaths_total) AS deaths_total,
			SUM(cd.tot_population) AS tot_population
		FROM county_cases_daily AS cc
		JOIN county_demographics AS cd
			USING (county_key)
        JOIN dim_county
			USING (county_key)
		WHERE csa_key IS NOT NULL
		GROUP BY
			csa_key,
            date_key
	) AS t
) AS t
;

INSERT INTO `msa_cases_daily` (
	msa_key,
    date_key,
    cases_new,
    deaths_new,
    cases_total,
    deaths_total,
    cases_new_per_100k,
    deaths_new_per_100k,
    cases_total_per_100k,
    deaths_total_per_100k,
    case_rate,
    mortality_rate,
    case_rate_per_100k,
    mortality_rate_per_100k
) SELECT
	msa_key,
	date_key,
	cases_new,
	deaths_new,
	cases_total,
	deaths_total,
	cases_new / tot_population * 100000 as cases_new_per_100k,
	deaths_new / tot_population * 100000 as deaths_new_per_100k,
	cases_total / tot_population * 100000 as cases_total_per_100k,
	deaths_total / tot_population * 100000 as deaths_total_per_100k,
    case_rate,
    mortality_rate,
	case_rate / tot_population * 100000 as case_rate_per_100k,
	mortality_rate / tot_population * 100000 as mortality_rate_per_100k
FROM (
	SELECT
		*,
        AVG(cases_new) OVER(PARTITION BY msa_key ORDER BY date_key
								ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING)
			AS case_rate,
		AVG(deaths_new) OVER(PARTITION BY msa_key ORDER BY date_key
								ROWS BETWEEN 6 PRECEDING AND 1 FOLLOWING)
			AS mortality_rate
	FROM (
		SELECT
    		dim_county.msa_key,
			cc.date_key AS date_key,
			SUM(cc.cases_new) AS cases_new,
			SUM(cc.deaths_new) AS deaths_new,
			SUM(cc.cases_total) AS cases_total,
			SUM(cc.deaths_total) AS deaths_total,
			SUM(cd.tot_population) AS tot_population
		FROM county_cases_daily AS cc
		JOIN county_demographics AS cd
			USING (county_key)
        JOIN dim_county
			USING (county_key)
		WHERE msa_key IS NOT NULL
		GROUP BY
			msa_key,
            date_key
	) AS t
) AS t
;
