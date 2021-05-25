
CREATE DATABASE IF NOT EXISTS `covid`;

CREATE SCHEMA IF NOT EXISTS `covid`;
USE `covid`;

CREATE TABLE IF NOT EXISTS `state` (
    `state_id` VARCHAR(2) NOT NULL,
	`name` VARCHAR(50) NOT NULL,
    `abbrev`  VARCHAR(2) NOT NULL,
    `state_fips` VARCHAR(2) NOT NULL,
    `feature_code` VARCHAR(8) NOT NULL,
    `lsad_code` VARCHAR(2) NOT NULL,
    `land_area` BIGINT NOT NULL,
    `water_area` BIGINT NOT NULL,
    PRIMARY KEY (`state_id`),
	UNIQUE KEY (`state_fips`),
    INDEX `state_name_idx` (`name`),
    INDEX `state_abbrev_idx` (`abbrev`),
    INDEX `state_fips_idx` (`state_fips`)
);

CREATE TABLE IF NOT EXISTS `county` (
	`county_id` VARCHAR(5) NOT NULL,
	`name` VARCHAR(50) NOT NULL,
	`county_fips` VARCHAR(3) NOT NULL,
	`state_fips` VARCHAR(2) NOT NULL,
	`feature_code` VARCHAR(8) NOT NULL,
	`lsad_code` VARCHAR(2) NOT NULL,
	`land_area` BIGINT,
	`water_area` BIGINT,
    PRIMARY KEY (`county_id`),
    UNIQUE KEY (`state_fips`, `county_fips`),
    INDEX `county_state_fips_idx` (`state_fips`),
    INDEX `county_name_idx` (`name`),
    INDEX `county_fips_idx` (`state_fips`, `county_fips`),
	CONSTRAINT `county_state_fips_fk`
		FOREIGN KEY (`state_fips`)
		REFERENCES `state` (`state_fips`)
);

CREATE TABLE IF NOT EXISTS `csa` (
	`csa_id` INT NOT NULL,
	`csa_fips` VARCHAR(6) NOT NULL,
	`name` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`csa_id`),
    UNIQUE KEY (`name`),
    INDEX `csa_csa_id_idx` (`csa_id`),
    INDEX `csa_name_idx` (`name`)
);

CREATE TABLE IF NOT EXISTS `msa` (
	`msa_id` INT NOT NULL,
	`msa_fips` VARCHAR(6) NOT NULL,
	`name` VARCHAR(100) NOT NULL,
    `type` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`msa_id`),
    UNIQUE KEY (`name`),
    INDEX `msa_msa_id_idx` (`msa_id`),
    INDEX `msa_name_idx` (`name`)
);

CREATE TABLE IF NOT EXISTS `county_msa` (
	`county_id` VARCHAR(5) NOT NULL,
	`msa_id` INT NOT NULL,
	`csa_id` INT NOT NULL,
    `centrality` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`county_id`, `msa_id`),
    INDEX `county_msa_county_pk_idx` (`county_id`, `msa_id`),
    INDEX `county_msa_msa_id_idx` (`msa_id`),
    INDEX `county_msa_csa_id_idx` (`csa_id`),
	CONSTRAINT `county_msa_county_id_fk`
		FOREIGN KEY (`county_id`)
		REFERENCES `county` (`county_id`),
	CONSTRAINT `county_msa_msa_id_fk`
		FOREIGN KEY (`msa_id`)
		REFERENCES `msa` (`msa_id`),
	CONSTRAINT `county_msa_csa_id_fk`
		FOREIGN KEY (`csa_id`)
		REFERENCES `csa` (`csa_id`)
);
