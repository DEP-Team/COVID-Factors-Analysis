
CREATE DATABASE IF NOT EXISTS `covid_dw`;
USE `covid_dw`;

CREATE TABLE IF NOT EXISTS `dim_state` (
	`state_key` INT NOT NULL AUTO_INCREMENT,
    `state_id` VARCHAR(2) NOT NULL,
	`name` VARCHAR(50) NOT NULL,
    `abbrev`  VARCHAR(2) NOT NULL,
    `state_fips` VARCHAR(2) NOT NULL,
    `feature_code` VARCHAR(8) NOT NULL,
    `lsad_code` VARCHAR(2) NOT NULL,
    `land_area` BIGINT NOT NULL,
    `water_area` BIGINT NOT NULL,
    PRIMARY KEY (`state_key`),
	UNIQUE KEY (`state_id`),
    UNIQUE KEY (`state_fips`),
    INDEX `state_name_idx` (`name`),
    INDEX `state_abbrev_idx` (`abbrev`),
    INDEX `state_id_idx` (`state_id`),
    INDEX `state_fips_idx` (`state_fips`)
);

CREATE TABLE IF NOT EXISTS `dim_csa` (
	`csa_key` INT NOT NULL AUTO_INCREMENT,
	`csa_id` INT NOT NULL,
	`name` VARCHAR(100) NOT NULL,
    `type` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`csa_key`),
    UNIQUE KEY (`csa_id`),
    UNIQUE KEY (`name`),
    INDEX `csa_csa_key_idx` (`csa_key`),
    INDEX `csa_csa_id_idx` (`csa_id`),
    INDEX `csa_name_idx` (`name`)
);

CREATE TABLE IF NOT EXISTS `dim_county` (
	`county_key` INT NOT NULL AUTO_INCREMENT,
    `state_key` INT NOT NULL,
    `csa_key` INT NULL,
	`county_id` VARCHAR(5) NOT NULL,
	`name` VARCHAR(50) NOT NULL,
	`county_fips` VARCHAR(3) NOT NULL,
	`state_fips` VARCHAR(2) NOT NULL,
	`feature_code` VARCHAR(8) NOT NULL,
	`lsad_code` VARCHAR(2) NOT NULL,
	`land_area` BIGINT,
	`water_area` BIGINT,
    `csa_centrality` VARCHAR(10) NULL,
    PRIMARY KEY (`county_key`),
    UNIQUE KEY (`county_id`),
    INDEX `county_state_key_idx` (`state_key`),
	INDEX `county_csa_key_idx` (`csa_key`),
    INDEX `county_id_idx` (`county_id`),
    INDEX `county_name_idx` (`name`),
	CONSTRAINT `county_state_key_fk`
		FOREIGN KEY (`state_key`)
		REFERENCES `state` (`state_key`),
	CONSTRAINT `county_csa_key_fk`
		FOREIGN KEY (`csa_key`)
		REFERENCES `csa` (`csa_key`)
);
