CREATE DATABASE IF NOT EXISTS `covid_dw`;
USE covid_dw;

CREATE TABLE IF NOT EXISTS `county_cases_daily` (
	county_date_key INT NOT NULL AUTO_INCREMENT,
	county_key VARCHAR(5) NOT NULL,
	date_key INT NOT NULL,
	county_date_id VARCHAR(13) NOT NULL,
	cases_new SMALLINT NOT NULL DEFAULT 0,
	deaths_new SMALLINT NOT NULL DEFAULT 0,
	cases_total INT NOT NULL DEFAULT 0,
	deaths_total INT NOT NULL DEFAULT 0,
	cases_new_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_new_per_100k FLOAT NOT NULL DEFAULT 0,
	cases_total_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_total_per_100k FLOAT NOT NULL DEFAULT 0,
	case_rate FLOAT NOT NULL DEFAULT 0,
	death_rate FLOAT NOT NULL DEFAULT 0,
	case_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	death_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	PRIMARY KEY (county_date_key),
	UNIQUE KEY (county_date_id),
	UNIQUE KEY (county_key, date_key),
	INDEX county_cases_daily_county_date_key_idx (county_date_key),
	INDEX county_cases_daily_county_key_date_key_idx (county_key, date_key),
	INDEX county_cases_daily_date_key_idx (date_key)
);

-- @TODO: state_cases_daily (view)
-- @TODO: msa_cases_daily (view)
-- @TODO: csa_cases_daily (view)
-- @TODO: state_cases_weekly (view)
-- @TODO: msa_cases_daily (view)

