CREATE DATABASE IF NOT EXISTS `covid`;
USE covid;

CREATE TABLE IF NOT EXISTS `county_cases` (
	county_date_id VARCHAR(13) NOT NULL,
	county_id VARCHAR(5) NOT NULL,
	date_id INT NOT NULL,
	positives_new SMALLINT NOT NULL DEFAULT 0,
	deaths_new SMALLINT NOT NULL DEFAULT 0,
	positives_total INT NOT NULL DEFAULT 0,
	deaths_total INT NOT NULL DEFAULT 0,
	PRIMARY KEY (county_date_id),
	UNIQUE KEY (county_id, date_id),
	INDEX county_cases_county_id_date_id_idx (county_id, date_id),
	INDEX county_cases_date_id_idx (date_id)
);