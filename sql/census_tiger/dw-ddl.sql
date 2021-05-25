
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
    INDEX `dim_state_name_idx` (`name`),
    INDEX `dim_state_abbrev_idx` (`abbrev`),
    INDEX `dim_state_id_idx` (`state_id`),
    INDEX `dim_state_fips_idx` (`state_fips`)
);

CREATE TABLE IF NOT EXISTS `dim_csa` (
	`csa_key` INT NOT NULL AUTO_INCREMENT,
	`csa_id` INT NOT NULL,
	`csa_fips` VARCHAR(6) NULL,
	`name` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`csa_key`),
    UNIQUE KEY (`csa_id`),
    UNIQUE KEY (`name`),
    INDEX `dim_csa_csa_key_idx` (`csa_key`),
    INDEX `dim_csa_csa_id_idx` (`csa_id`),
    INDEX `dim_csa_name_idx` (`name`)
);

CREATE TABLE IF NOT EXISTS `dim_msa` (
	`msa_key` INT NOT NULL AUTO_INCREMENT,
	`msa_id` INT NOT NULL,
	`msa_fips` VARCHAR(6) NULL,
	`name` VARCHAR(100) NOT NULL,
    `type` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`msa_key`),
    UNIQUE KEY (`msa_id`),
    UNIQUE KEY (`name`),
    INDEX `dim_msa_msa_key_idx` (`msa_key`),
    INDEX `dim_msa_msa_id_idx` (`msa_id`),
    INDEX `dim_msa_name_idx` (`name`)
);

CREATE TABLE IF NOT EXISTS `dim_county` (
	`county_key` INT NOT NULL AUTO_INCREMENT,
    `state_key` INT NOT NULL,
    `csa_key` INT NULL,
    `msa_key` INT NULL,
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
    INDEX `dim_county_state_key_idx` (`state_key`),
	INDEX `dim_county_csa_key_idx` (`csa_key`),
	INDEX `dim_county_msa_key_idx` (`msa_key`),
    INDEX `dim_county_id_idx` (`county_id`),
    INDEX `dim_county_name_idx` (`name`),
	CONSTRAINT `dim_county_state_key_fk`
		FOREIGN KEY (`state_key`)
		REFERENCES `dim_state` (`state_key`),
	CONSTRAINT `dim_county_csa_key_fk`
		FOREIGN KEY (`csa_key`)
		REFERENCES `dim_csa` (`csa_key`),
	CONSTRAINT `dim_county_msa_key_fk`
		FOREIGN KEY (`msa_key`)
		REFERENCES `dim_msa` (`msa_key`)
);

