CREATE DATABASE IF NOT EXISTS `covid_dw`;
USE covid_dw;

CREATE TABLE IF NOT EXISTS `county_cases_daily` (
	county_date_key INT NOT NULL AUTO_INCREMENT,
	county_key INT NOT NULL,
	date_key INT NOT NULL,
	cases_new SMALLINT NOT NULL DEFAULT 0,
	deaths_new SMALLINT NOT NULL DEFAULT 0,
	cases_total INT NOT NULL DEFAULT 0,
	deaths_total INT NOT NULL DEFAULT 0,
	cases_new_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_new_per_100k FLOAT NOT NULL DEFAULT 0,
	cases_total_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_total_per_100k FLOAT NOT NULL DEFAULT 0,
	case_rate FLOAT NOT NULL DEFAULT 0,
	mortality_rate FLOAT NOT NULL DEFAULT 0,
	case_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	mortality_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	PRIMARY KEY (county_date_key),
	UNIQUE KEY (county_key, date_key),
	INDEX county_cases_daily_county_date_key_idx (county_date_key),
	INDEX county_cases_daily_county_key_date_key_idx (county_key, date_key),
	INDEX county_cases_daily_date_key_idx (date_key),
	CONSTRAINT `dim_county_cases_daily_county_key_fk`
		FOREIGN KEY (`county_key`)
		REFERENCES `dim_county` (`county_key`),
	CONSTRAINT `dim_county_cases_daily_date_key_fk`
		FOREIGN KEY (`date_key`)
		REFERENCES `dim_date` (`date_key`)
);

CREATE TABLE IF NOT EXISTS `state_cases_daily` (
	state_date_key INT NOT NULL AUTO_INCREMENT,
	state_key INT NOT NULL,
	date_key INT NOT NULL,
	cases_new INT NOT NULL DEFAULT 0,
	deaths_new INT NOT NULL DEFAULT 0,
	cases_total INT NOT NULL DEFAULT 0,
	deaths_total INT NOT NULL DEFAULT 0,
	cases_new_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_new_per_100k FLOAT NOT NULL DEFAULT 0,
	cases_total_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_total_per_100k FLOAT NOT NULL DEFAULT 0,
	case_rate FLOAT NOT NULL DEFAULT 0,
	mortality_rate FLOAT NOT NULL DEFAULT 0,
	case_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	mortality_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	PRIMARY KEY (state_date_key),
	UNIQUE KEY (state_key, date_key),
	INDEX state_cases_daily_state_date_key_idx (state_date_key),
	INDEX state_cases_daily_state_key_date_key_idx (state_key, date_key),
	INDEX state_cases_daily_date_key_idx (date_key),
	CONSTRAINT `dim_state_cases_daily_county_key_fk`
		FOREIGN KEY (`state_key`)
		REFERENCES `dim_state` (`state_key`),
	CONSTRAINT `dim_state_cases_daily_date_key_fk`
		FOREIGN KEY (`date_key`)
		REFERENCES `dim_date` (`date_key`)
);

CREATE TABLE IF NOT EXISTS `csa_cases_daily` (
	csa_date_key INT NOT NULL AUTO_INCREMENT,
	csa_key INT NOT NULL,
	date_key INT NOT NULL,
	cases_new INT NOT NULL DEFAULT 0,
	deaths_new INT NOT NULL DEFAULT 0,
	cases_total INT NOT NULL DEFAULT 0,
	deaths_total INT NOT NULL DEFAULT 0,
	cases_new_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_new_per_100k FLOAT NOT NULL DEFAULT 0,
	cases_total_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_total_per_100k FLOAT NOT NULL DEFAULT 0,
	case_rate FLOAT NOT NULL DEFAULT 0,
	mortality_rate FLOAT NOT NULL DEFAULT 0,
	case_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	mortality_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	PRIMARY KEY (csa_date_key),
	UNIQUE KEY (csa_key, date_key),
	INDEX csa_cases_daily_csa_date_key_idx (csa_date_key),
	INDEX csa_cases_daily_csa_key_date_key_idx (csa_key, date_key),
	INDEX csa_cases_daily_date_key_idx (date_key),
	CONSTRAINT `dim_csa_cases_daily_csa_key_fk`
		FOREIGN KEY (`csa_key`)
		REFERENCES `dim_csa` (`csa_key`),
	CONSTRAINT `dim_csa_cases_daily_date_key_fk`
		FOREIGN KEY (`date_key`)
		REFERENCES `dim_date` (`date_key`)
);

CREATE TABLE IF NOT EXISTS `msa_cases_daily` (
	msa_date_key INT NOT NULL AUTO_INCREMENT,
	msa_key INT NOT NULL,
	date_key INT NOT NULL,
	cases_new INT NOT NULL DEFAULT 0,
	deaths_new INT NOT NULL DEFAULT 0,
	cases_total INT NOT NULL DEFAULT 0,
	deaths_total INT NOT NULL DEFAULT 0,
	cases_new_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_new_per_100k FLOAT NOT NULL DEFAULT 0,
	cases_total_per_100k FLOAT NOT NULL DEFAULT 0,
	deaths_total_per_100k FLOAT NOT NULL DEFAULT 0,
	case_rate FLOAT NOT NULL DEFAULT 0,
	mortality_rate FLOAT NOT NULL DEFAULT 0,
	case_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	mortality_rate_per_100k FLOAT NOT NULL DEFAULT 0,
	PRIMARY KEY (msa_date_key),
	UNIQUE KEY (msa_key, date_key),
	INDEX msa_cases_daily_msa_date_key_idx (msa_date_key),
	INDEX msa_cases_daily_msa_key_date_key_idx (msa_key, date_key),
	INDEX msa_cases_daily_date_key_idx (date_key),
	CONSTRAINT `dim_msa_cases_daily_msa_key_fk`
		FOREIGN KEY (`msa_key`)
		REFERENCES `dim_msa` (`msa_key`),
	CONSTRAINT `dim_msa_cases_daily_date_key_fk`
		FOREIGN KEY (`date_key`)
		REFERENCES `dim_date` (`date_key`)
);

-- @TODO: state_cases_weekly (view)
-- @TODO: msa_cases_daily (view)

CREATE VIEW v_excess_case_rate AS
SELECT
	cd1.county_key,
	c.state_key,
    cd1.date_key,
	v_date_lead.date,
    cd1.case_rate_per_100k AS county_case_rate_per_100k,
    sd1.case_rate_per_100k AS state_case_rate_per_100k,
	cd1.case_rate_per_100k - sd1.case_rate_per_100k AS county_excess_cases,
    wk4_date,
    cd2.case_rate_per_100k AS county_case_rate_per_100k_after_4wk,
    sd2.case_rate_per_100k AS state_case_rate_per_100k_after_4wk,
	cd2.case_rate_per_100k - sd2.case_rate_per_100k AS county_excess_cases_after_4wk,
    (cd2.case_rate_per_100k - cd1.case_rate_per_100k) AS county_case_rate_delta,
    (sd2.case_rate_per_100k - sd1.case_rate_per_100k) AS state_case_rate_delta,
    ((cd2.case_rate_per_100k - sd2.case_rate_per_100k) - (cd1.case_rate_per_100k - sd1.case_rate_per_100k)) AS county_excess_case_rate_delta
FROM county_cases_daily AS cd1
JOIN v_date_lead
	USING (date_key)
JOIN county_cases_daily AS cd2
	ON cd2.date_key = CAST(DATE_FORMAT(v_date_lead.wk4_date, "%Y%m%d") AS UNSIGNED)
    AND cd1.county_key = cd2.county_key
JOIN dim_county AS c
	ON c.county_key = cd1.county_key
JOIN state_cases_daily AS sd1
	ON sd1.date_key = cd1.date_key
	AND sd1.state_key = c.state_key
JOIN state_cases_daily AS sd2
	ON sd2.date_key = CAST(DATE_FORMAT(v_date_lead.wk4_date, "%Y%m%d") AS UNSIGNED)
    AND sd1.state_key = sd2.state_key
;