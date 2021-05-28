CREATE DATABASE IF NOT EXISTS `covid`;
USE covid;

CREATE TABLE IF NOT EXISTS `county_cases` (
	county_id VARCHAR(5) NOT NULL,
	date_id INT NOT NULL,
	new_cases SMALLINT NOT NULL DEFAULT 0,
	new_deaths SMALLINT NOT NULL DEFAULT 0,
	total_cases INT NOT NULL DEFAULT 0,
	total_deaths INT NOT NULL DEFAULT 0,
	PRIMARY KEY (county_id, date_id),
	UNIQUE KEY (county_id, date_id),
	INDEX county_cases_county_id_date_id_idx (county_id, date_id),
	INDEX county_cases_date_id_idx (date_id),
	CONSTRAINT `county_cases_county_id_fk`
		FOREIGN KEY (`county_id`)
		REFERENCES `county` (`county_id`),
	CONSTRAINT `county_cases_date_id_fk`
		FOREIGN KEY (`date_id`)
		REFERENCES `date` (`date_id`)
);