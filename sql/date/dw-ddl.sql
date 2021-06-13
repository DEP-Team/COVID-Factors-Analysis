use covid_dw;

CREATE TABLE IF NOT EXISTS `dim_date` (
    date_key INT NOT NULL,
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
    PRIMARY KEY (`date_key`),
	UNIQUE KEY `date` (`date`),
	KEY `date_year_week` (`year`,`week_of_year`),
	INDEX `date_date_key_idx` (`date_key`),
	INDEX `date_date_idx` (`date`)
);

CREATE VIEW v_date_lead AS
SELECT
	date_key,
	date,
    DATE_ADD(date, INTERVAL 14 DAY) wk2_date,
    DATE_ADD(date, INTERVAL 28 DAY) wk4_date,
    DATE_ADD(date, INTERVAL 42 DAY) wk6_date
FROM dim_date
;
