-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `covid`;
USE `covid`;

-- -----------------------------------------------------
-- Table `characteristic_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `characteristic_type` (
  `characteristic_type_id` INT NOT NULL AUTO_INCREMENT,
  `label` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`characteristic_type_id`),
  UNIQUE KEY (`characteristic_type_id`),
  UNIQUE KEY (`label`),
  INDEX `characteristic_type_characteristic_type_id_idx` (`characteristic_type_id`),
  INDEX `characteristic_type_label_idx` (`label`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `characteristic`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `characteristic` (
  `characteristic_id` INT NOT NULL AUTO_INCREMENT,
  `characteristic_type_id` INT NOT NULL,
  `label` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`characteristic_id`),
  UNIQUE KEY (`characteristic_id`),
  UNIQUE KEY (`characteristic_type_id`, `label`),
  INDEX `characteristic_characteristic_id_idx` (`characteristic_id`),
  INDEX `characteristic_characteristic_type_id_idx` (`characteristic_type_id`),
  INDEX `characteristic_label_idx` (`label`),
  CONSTRAINT `characteristic_characteristic_type_fk`
    FOREIGN KEY (`characteristic_type_id`)
    REFERENCES `characteristic_type` (`characteristic_type_id`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `question`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `question` (
  `question_id` INT NOT NULL AUTO_INCREMENT,
  `table` VARCHAR(20) NOT NULL,
  `label` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`question_id`),
  UNIQUE KEY (`question_id`),
  UNIQUE KEY (`table`, `label`),
  INDEX `question_question_id_idx` (`question_id`),
  INDEX `question_table` (`table`),
  INDEX `question_label` (`label`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `response`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `response` (
  `response_id` INT NOT NULL AUTO_INCREMENT,
  `question_id` INT NOT NULL,
  `choice` VARCHAR(20) NOT NULL,
  `subchoice` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`response_id`),
  UNIQUE KEY (`response_id`),
  UNIQUE KEY (`question_id`, `choice`, `subchoice`),
  INDEX `response_response_id_idx` (`response_id`),
  INDEX `response_question_id_idx` (`question_id`),
  INDEX `response_choice_idx` (`question_id`, `choice`, `subchoice`),
  CONSTRAINT `response_question_id_fk`
    FOREIGN KEY (`question_id`)
    REFERENCES `question` (`question_id`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `region`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `region` (
  `region_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  `type` VARCHAR(8) NOT NULL,
  `fips_code` VARCHAR(6) NOT NULL,
  PRIMARY KEY (`region_id`),
  UNIQUE KEY (`region_id`),
  UNIQUE KEY (`type`, `name`),
  UNIQUE KEY (`fips_code`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `survey`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `survey` (
  `survey_id` INT NOT NULL AUTO_INCREMENT,
  `week_label` INT NOT NULL,
  `published_date_id` INT NOT NULL,
  `collection_start_date_id` INT NOT NULL,
  `collection_end_date_id` INT NOT NULL,
  PRIMARY KEY (`survey_id`),
  UNIQUE KEY (`survey_id`),
  UNIQUE KEY (`week_label`),
  UNIQUE KEY (`published_date_id`),
  UNIQUE KEY (`collection_start_date_id`, `collection_end_date_id`),
  CONSTRAINT `survey_collection_start_date_id_fk`
    FOREIGN KEY (`collection_start_date_id`)
    REFERENCES `date` (`date_id`),
  CONSTRAINT `survey_collection_end_date_id_fk`
    FOREIGN KEY (`collection_end_date_id`)
    REFERENCES `date` (`date_id`),
  CONSTRAINT `survey_published_date_id_fk`
    FOREIGN KEY (`published_date_id`)
    REFERENCES `date` (`date_id`)
)
ENGINE = InnoDB
;

-- -----------------------------------------------------
-- Table `survey_response`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `survey_response` (
  `survey_response_id` INT NOT NULL,
  `survey_id` INT NOT NULL,
  `region_id` INT NOT NULL,
  `response_id` INT NOT NULL,
  `characteristic_id` INT NOT NULL,
  `respondents_count` INT NOT NULL,
  PRIMARY KEY (`survey_response_id`),
  UNIQUE KEY (`survey_id`, `region_id`, `response_id`, `characteristic_id`),
  INDEX `survey_response_survey_response_id_idx` (`survey_response_id` ASC) VISIBLE,
  INDEX `survey_response_survey_id_idx` (`survey_id`),
  INDEX `survey_response_region_id_idx` (`region_id` ASC) VISIBLE,
  INDEX `survey_response_response_id_idx` (`response_id` ASC) VISIBLE,
  INDEX `survey_response_characteristic_id_idx` (`characteristic_id` ASC) VISIBLE,
  CONSTRAINT `survey_response_survey_id_fk`
    FOREIGN KEY (`survey_id`)
    REFERENCES `survey` (`survey_id`),
  CONSTRAINT `survey_response_region_id_fk`
    FOREIGN KEY (`region_id`)
    REFERENCES `region` (`region_id`),
  CONSTRAINT `survey_response_response_id_fk`
    FOREIGN KEY (`response_id`)
    REFERENCES `response` (`response_id`),
  CONSTRAINT `survey_response_characteristic_id_fk`
    FOREIGN KEY (`characteristic_id`)
    REFERENCES `characteristic` (`characteristic_id`)
)
ENGINE = InnoDB
;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
