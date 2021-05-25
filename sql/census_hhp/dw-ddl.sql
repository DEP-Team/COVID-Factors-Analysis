-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `covid_dw`;
USE `covid_dw`;

-- -----------------------------------------------------
-- Table `characteristic_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_characteristic_type` (
  `characteristic_type_key` INT NOT NULL AUTO_INCREMENT,
  `characteristic_type_id` INT NOT NULL,
  `label` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`characteristic_type_key`),
  UNIQUE KEY (`characteristic_type_key`),
  UNIQUE KEY (`characteristic_type_id`),
  UNIQUE KEY (`label`),
  INDEX `dim_characteristic_type_characteristic_type_key_idx` (`characteristic_type_key`),
  INDEX `dim_characteristic_type_characteristic_type_id_idx` (`characteristic_type_id`),
  INDEX `dim_characteristic_type_label_idx` (`label`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `characteristic`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_characteristic` (
  `characteristic_key` INT NOT NULL AUTO_INCREMENT,
  `characteristic_type_key` INT NOT NULL,
  `characteristic_id` INT NOT NULL,
  `label` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`characteristic_key`),
  UNIQUE KEY (`characteristic_key`),
  UNIQUE KEY (`characteristic_id`),
  UNIQUE KEY (`characteristic_type_key`, `label`),
  INDEX `dim_characteristic_characteristic_key_idx` (`characteristic_key`),
  INDEX `dim_characteristic_characteristic_id_idx` (`characteristic_id`),
  INDEX `dim_characteristic_characteristic_type_key_idx` (`characteristic_type_key`),
  INDEX `dim_characteristic_label_idx` (`label`),
  CONSTRAINT `dim_characteristic_characteristic_type_fk`
    FOREIGN KEY (`characteristic_type_key`)
    REFERENCES `dim_characteristic_type` (`characteristic_type_key`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `response`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_response` (
  `response_key` INT NOT NULL AUTO_INCREMENT,
  `response_id` INT NOT NULL,
  `question_id` INT NOT NULL,
  `question_table` VARCHAR(20) NOT NULL,
  `question_label` VARCHAR(100) NOT NULL,
  `choice` VARCHAR(20) NOT NULL,
  `subchoice` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`response_key`),
  UNIQUE KEY (`response_key`),
  UNIQUE KEY (`response_id`),
  UNIQUE KEY (`question_id`, `choice`, `subchoice`),
  INDEX `dim_response_response_key_idx` (`response_key`),
  INDEX `dim_response_response_id_idx` (`response_id`),
  INDEX `dim_response_question_id_idx` (`question_id`),
  INDEX `dim_response_choice_idx` (`question_id`, `choice`, `subchoice`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `survey`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_survey` (
  `survey_key` INT NOT NULL AUTO_INCREMENT,
  `collection_start_date_key` INT NOT NULL,
  `collection_end_date_key` INT NOT NULL,
  `published_date_key` INT NOT NULL,
  `survey_id` INT NOT NULL,
  `week_label` INT NOT NULL,
  PRIMARY KEY (`survey_key`),
  UNIQUE KEY (`survey_key`),
  UNIQUE KEY (`survey_id`),
  UNIQUE KEY (`week_label`),
  UNIQUE KEY (`published_date_key`),
  UNIQUE KEY (`collection_start_date_key`, `collection_end_date_key`),
  INDEX `dim_survey_collection_start_date_key_idx` (`collection_start_date_key`),
  INDEX `dim_survey_collection_end_date_key_idx` (`collection_end_date_key`),
  INDEX `dim_survey_published_date_key_idx` (`published_date_key`),
  CONSTRAINT `dim_survey_collection_start_date_key_fk`
    FOREIGN KEY (`collection_start_date_key`)
    REFERENCES `dim_date` (`date_key`),
  CONSTRAINT `dim_survey_collection_end_date_key_fk`
    FOREIGN KEY (`collection_end_date_key`)
    REFERENCES `dim_date` (`date_key`),
  CONSTRAINT `dim_survey_published_date_key_fk`
    FOREIGN KEY (`published_date_key`)
    REFERENCES `dim_date` (`date_key`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `survey_response`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `us_survey_response` (
  `us_survey_response_key` INT NOT NULL AUTO_INCREMENT,
  `survey_key` INT NOT NULL,
  `response_key` INT NOT NULL,
  `characteristic_key` INT NOT NULL,
  `survey_response_id` INT NOT NULL,
  `respondents_count` INT NOT NULL,
  PRIMARY KEY (`us_survey_response_key`),
  UNIQUE KEY (`us_survey_response_key`),
  UNIQUE KEY (`survey_key`, `response_key`, `characteristic_key`),
  INDEX `dim_us_survey_response_us_survey_response_key_idx` (`us_survey_response_key`),
  INDEX `dim_us_survey_response_survey_response_id_idx` (`survey_response_id`),
  INDEX `dim_us_survey_response_survey_key_idx` (`survey_key`),
  INDEX `dim_us_survey_response_response_key_idx` (`response_key`),
  INDEX `dim_us_survey_response_characteristic_key_idx` (`characteristic_key`),
  CONSTRAINT `dim_us_survey_response_survey_key_fk`
    FOREIGN KEY (`survey_key`)
    REFERENCES `dim_survey` (`survey_key`),
  CONSTRAINT `dim_us_survey_response_response_key_fk`
    FOREIGN KEY (`response_key`)
    REFERENCES `dim_response` (`response_key`),
  CONSTRAINT `dim_us_survey_response_characteristic_key_fk`
    FOREIGN KEY (`characteristic_key`)
    REFERENCES `dim_characteristic` (`characteristic_key`)
)
ENGINE = InnoDB
;

CREATE TABLE IF NOT EXISTS `state_survey_response` (
  `state_survey_response_key` INT NOT NULL AUTO_INCREMENT,
  `state_key` INT NOT NULL,
  `survey_key` INT NOT NULL,
  `response_key` INT NOT NULL,
  `characteristic_key` INT NOT NULL,
  `survey_response_id` INT NOT NULL,
  `respondents_count` INT NOT NULL,
  PRIMARY KEY (`state_survey_response_key`),
  UNIQUE KEY (`state_survey_response_key`),
  UNIQUE KEY (`state_key`, `survey_key`, `response_key`, `characteristic_key`),
  INDEX `dim_state_survey_response_state_survey_response_key_idx` (`state_survey_response_key`),
  INDEX `dim_state_survey_response_survey_response_id_idx` (`survey_response_id`),
  INDEX `dim_state_survey_response_state_key_idx` (`state_key`),
  INDEX `dim_state_survey_response_survey_key_idx` (`survey_key`),
  INDEX `dim_state_survey_response_response_key_idx` (`response_key`),
  INDEX `dim_state_survey_response_characteristic_key_idx` (`characteristic_key`),
   CONSTRAINT `dim_state_survey_response_state_key_fk`
    FOREIGN KEY (`state_key`)
    REFERENCES `dim_state` (`state_key`),
  CONSTRAINT `dim_state_survey_response_survey_key_fk`
    FOREIGN KEY (`survey_key`)
    REFERENCES `dim_survey` (`survey_key`),
  CONSTRAINT `dim_state_survey_response_response_key_fk`
    FOREIGN KEY (`response_key`)
    REFERENCES `dim_response` (`response_key`),
  CONSTRAINT `dim_state_survey_response_characteristic_key_fk`
    FOREIGN KEY (`characteristic_key`)
    REFERENCES `dim_characteristic` (`characteristic_key`)
)
ENGINE = InnoDB
;

CREATE TABLE IF NOT EXISTS `msa_survey_response` (
  `msa_survey_response_key` INT NOT NULL AUTO_INCREMENT,
  `msa_key` INT NOT NULL,
  `survey_key` INT NOT NULL,
  `response_key` INT NOT NULL,
  `characteristic_key` INT NOT NULL,
  `survey_response_id` INT NOT NULL,
  `respondents_count` INT NOT NULL,
  PRIMARY KEY (`msa_survey_response_key`),
  UNIQUE KEY (`msa_survey_response_key`),
  UNIQUE KEY (`msa_key`, `survey_key`, `response_key`, `characteristic_key`),
  INDEX `dim_msa_survey_response_msa_survey_response_key_idx` (`msa_survey_response_key`),
  INDEX `dim_msa_survey_response_survey_response_id_idx` (`survey_response_id`),
  INDEX `dim_msa_survey_response_msa_key_idx` (`msa_key`),
  INDEX `dim_msa_survey_response_survey_key_idx` (`survey_key`),
  INDEX `dim_msa_survey_response_response_key_idx` (`response_key`),
  INDEX `dim_msa_survey_response_characteristic_key_idx` (`characteristic_key`),
   CONSTRAINT `dim_msa_survey_response_msa_key_fk`
    FOREIGN KEY (`msa_key`)
    REFERENCES `dim_msa` (`msa_key`),
  CONSTRAINT `dim_msa_survey_response_survey_key_fk`
    FOREIGN KEY (`survey_key`)
    REFERENCES `dim_survey` (`survey_key`),
  CONSTRAINT `dim_msa_survey_response_response_key_fk`
    FOREIGN KEY (`response_key`)
    REFERENCES `dim_response` (`response_key`),
  CONSTRAINT `dim_msa_survey_response_characteristic_key_fk`
    FOREIGN KEY (`characteristic_key`)
    REFERENCES `dim_characteristic` (`characteristic_key`)
)
ENGINE = InnoDB
;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
