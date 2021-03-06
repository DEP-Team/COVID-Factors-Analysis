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

USE `covid_dw`;

###Sequence of summary views and summaries / inputs to vaccination rate overview by state###
#View - State_Overview
CREATE VIEW State_Overview AS
    SELECT
        state_survey_response.state_survey_response_key,
        dim_survey.week_label,
        dim_survey.published_date_key,
        dim_state.name,
        dim_characteristic_type.label AS type_label,
        dim_characteristic.label AS char_label,
        dim_response.choice,
        state_survey_response.respondents_count
    FROM
        state_survey_response,
        dim_state,
        dim_survey,
        dim_characteristic_type,
        dim_characteristic,
        dim_response
    WHERE
        state_survey_response.survey_key = dim_survey.survey_key
            AND state_survey_response.state_key = dim_state.state_key
            AND state_survey_response.characteristic_key = dim_characteristic.characteristic_key
            AND dim_characteristic.characteristic_type_key = dim_characteristic_type.characteristic_type_key
            AND state_survey_response.response_key = dim_response.response_key;

#State detail template (excl. 'intent')
CREATE VIEW State_detail_template AS
    SELECT
        *
    FROM
        covid_dw.State_Overview
    ORDER BY type_label , choice DESC;

#View - Total respondents summary
CREATE VIEW State_total_respondents_summary AS
    SELECT
        week_label, name, SUM(respondents_count) AS sum_of_resp
    FROM
        State_Overview
    WHERE
        type_label = 'Age Group'
    GROUP BY week_label , name;

#View - State vaccination counts summary
CREATE VIEW State_vaccination_counts AS
    SELECT
        week_label,
        name,
        choice,
        SUM(respondents_count) AS sum_of_resp
    FROM
        State_Overview
    WHERE
        type_label = 'Age Group'
    GROUP BY week_label , name , choice , type_label;

#View - State vaccination rates
CREATE VIEW State_vaccination_rates AS
    SELECT
        State_vaccination_counts.week_label,
        State_vaccination_counts.name,
        State_vaccination_counts.choice,
        State_vaccination_counts.sum_of_resp AS count_cat,
        State_total_respondents_summary.sum_of_resp AS count_tot
    FROM
        State_vaccination_counts,
        State_total_respondents_summary
    WHERE
        State_vaccination_counts.week_label = State_total_respondents_summary.week_label
            AND State_vaccination_counts.name = State_total_respondents_summary.name;

#View - State cases
CREATE VIEW State_cases_summary AS
    SELECT
        state_cases_daily.state_key,
        state_cases_daily.date_key,
        dim_date.date,
        dim_state.name,
        state_cases_daily.cases_new,
        state_cases_daily.cases_total
    FROM
        state_cases_daily,
        dim_date,
        dim_state
    WHERE
        state_cases_daily.date_key = dim_date.date_key
            AND state_cases_daily.state_key = dim_state.state_key;

#View - Not Vaccinated by Reason
CREATE VIEW Not_vaccinated_by_reason AS
    SELECT
        state_survey_response.state_survey_response_key,
        state_survey_response.respondents_count,
        dim_survey.survey_key,
        dim_date.date,
        dim_state.name,
        dim_response.choice,
        dim_characteristic.label AS char_label,
        dim_characteristic_type.label AS type_label
    FROM
        state_survey_response,
        dim_survey,
        dim_date,
        dim_state,
        dim_response,
        dim_characteristic,
        dim_characteristic_type
    WHERE
        state_survey_response.survey_key = dim_survey.survey_key
            AND dim_survey.published_date_key = dim_date.date_key
            AND state_survey_response.state_key = dim_state.state_key
            AND state_survey_response.response_key = dim_response.response_key
            AND state_survey_response.characteristic_key = dim_characteristic.characteristic_key
            AND dim_characteristic.characteristic_type_key = dim_characteristic_type.characteristic_type_key;

CREATE VIEW v_state_vaccination_headline_latest AS
SELECT
	state_key,
    abbrev,
    yes_count,
    no_count,
    dnr_count,
    total_count,
    yes_count / total_count * 100 yes_pct,
    no_count / total_count * 100 no_pct,
    dnr_count / total_count * 100 dnr_pct
FROM (
	SELECT
		state_key,
		abbrev,
		SUM(IF(choice = "Yes", respondents_count, 0)) yes_count,
		SUM(IF(choice = "No", respondents_count, 0)) no_count,
        SUM(IF(choice = "Did not report", respondents_count, 0)) dnr_count,
		SUM(respondents_count) total_count
	FROM state_survey_response AS ssr
	JOIN dim_state USING(state_key)
	JOIN dim_response USING(response_key)
	JOIN dim_characteristic USING (characteristic_key)
	WHERE survey_key IN (SELECT MAX(survey_key) FROM dim_survey)
		AND characteristic_type_key = 1
	GROUP BY
		state_key, abbrev
) AS t;

CREATE VIEW v_msa_vaccination_headline_latest AS
SELECT
	msa_key,
	msa_fips,
	name,
    yes_count,
    no_count,
    dnr_count,
    total_count,
    yes_count / total_count * 100 yes_pct,
    no_count / total_count * 100 no_pct,
    dnr_count / total_count * 100 dnr_pct
FROM (
	SELECT
		msa_key,
		SUM(IF(choice = "Yes", respondents_count, 0)) yes_count,
		SUM(IF(choice = "No", respondents_count, 0)) no_count,
        SUM(IF(choice = "Did not report", respondents_count, 0)) dnr_count,
		SUM(respondents_count) total_count
	FROM msa_survey_response AS msr
	JOIN dim_response USING(response_key)
	JOIN dim_characteristic USING (characteristic_key)
	WHERE survey_key IN (SELECT MAX(survey_key) FROM dim_survey)
		AND characteristic_type_key = 1
	GROUP BY
		msa_key
) AS t
 JOIN dim_msa USING(msa_key)
;

CREATE VIEW v_state_vaccine_hesitancy_headline_latest AS
SELECT
	state_key,
    abbrev AS state_abbrev,
	concerned_side_effects,
	concerned_efficacy,
	antivax,
	doctor_has_not_recommended_it,
	wait_and_see_if_safe,
	others_need_more,
	concerned_costs,
	mistrust_covid_vax,
	mistrust_govt,
	no_need_all,
	no_need_already_had_covid,
	no_need_not_high_risk,
	no_need_use_mask_instead,
	no_need_covid_not_serious,
	no_need_antivax,
	no_need_other,
	no_need_dnr,
	other_reason,
	did_not_report,

	concerned_side_effects / total_count * 100 AS concerned_side_effects_pct,
	concerned_efficacy / total_count * 100 AS concerned_efficacy_pct,
	antivax / total_count * 100 AS antivax_pct,
	doctor_has_not_recommended_it / total_count * 100 AS doctor_has_not_recommended_it_pct,
	wait_and_see_if_safe / total_count * 100 AS wait_and_see_if_safe_pct,
	others_need_more / total_count * 100 AS others_need_more_pct,
	concerned_costs / total_count * 100 AS concerned_costs_pct,
	mistrust_covid_vax / total_count * 100 AS mistrust_covid_vax_pct,
	mistrust_govt / total_count * 100 AS mistrust_govt_pct,
	no_need_all / total_count * 100 AS no_need_all_pct,
	no_need_already_had_covid / total_count * 100 AS no_need_already_had_covid_pct,
	no_need_not_high_risk / total_count * 100 AS no_need_not_high_risk_pct,
	no_need_use_mask_instead / total_count * 100 AS no_need_use_mask_instead_pct,
	no_need_covid_not_serious / total_count * 100 AS no_need_covid_not_serious_pct,
	no_need_antivax / total_count * 100 AS no_need_antivax_pct,
	no_need_other / total_count * 100 AS no_need_other_pct,
	no_need_dnr / total_count * 100 AS no_need_dnr_pct,
	other_reason / total_count * 100 AS other_reason_pct,
	did_not_report / total_count * 100 AS did_not_report_pct,

    mistrust,
    mistrust / total_count * 100 AS mistrust_pct,
    misinformed,
    misinformed / total_count * 100 AS misinformed_pct

FROM (
	SELECT
		state_key,
		SUM(IF(characteristic_id = 35, respondents_count, 0)) AS concerned_side_effects,
		SUM(IF(characteristic_id = 36, respondents_count, 0)) AS concerned_efficacy,
		SUM(IF(characteristic_id = 37, respondents_count, 0)) AS antivax,
		SUM(IF(characteristic_id = 38, respondents_count, 0)) AS doctor_has_not_recommended_it,
		SUM(IF(characteristic_id = 39, respondents_count, 0)) AS wait_and_see_if_safe,
		SUM(IF(characteristic_id = 40, respondents_count, 0)) AS others_need_more,
		SUM(IF(characteristic_id = 41, respondents_count, 0)) AS concerned_costs,
		SUM(IF(characteristic_id = 42, respondents_count, 0)) AS mistrust_covid_vax,
		SUM(IF(characteristic_id = 43, respondents_count, 0)) AS mistrust_govt,
		SUM(IF(characteristic_id = 44, respondents_count, 0)) AS no_need_all,
		SUM(IF(characteristic_id = 45, respondents_count, 0)) AS no_need_already_had_covid,
		SUM(IF(characteristic_id = 46, respondents_count, 0)) AS no_need_not_high_risk,
		SUM(IF(characteristic_id = 47, respondents_count, 0)) AS no_need_use_mask_instead,
		SUM(IF(characteristic_id = 48, respondents_count, 0)) AS no_need_covid_not_serious,
		SUM(IF(characteristic_id = 49, respondents_count, 0)) AS no_need_antivax,
		SUM(IF(characteristic_id = 50, respondents_count, 0)) AS no_need_other,
		SUM(IF(characteristic_id = 51, respondents_count, 0)) AS no_need_dnr,
		SUM(IF(characteristic_id = 52, respondents_count, 0)) AS other_reason,
		SUM(IF(characteristic_id = 53, respondents_count, 0)) AS did_not_report,
		SUM(IF(characteristic_id IN (42, 43), respondents_count, 0)) AS mistrust,
		SUM(IF(characteristic_id IN (48, 49), respondents_count, 0)) AS misinformed,
        SUM(respondents_count) AS total_count
	FROM state_survey_response
	JOIN dim_characteristic USING(characteristic_key)
	WHERE survey_key IN (SELECT MAX(survey_key) FROM dim_survey)
		AND characteristic_type_key = 7
	GROUP BY
		state_key
) AS t
JOIN dim_state USING (state_key)
;

CREATE VIEW v_msa_vaccine_hesitancy_headline_latest AS
SELECT
	msa_key,
    name AS msa_name,
	concerned_side_effects,
	concerned_efficacy,
	antivax,
	doctor_has_not_recommended_it,
	wait_and_see_if_safe,
	others_need_more,
	concerned_costs,
	mistrust_covid_vax,
	mistrust_govt,
	no_need_all,
	no_need_already_had_covid,
	no_need_not_high_risk,
	no_need_use_mask_instead,
	no_need_covid_not_serious,
	no_need_antivax,
	no_need_other,
	no_need_dnr,
	other_reason,
	did_not_report,

	concerned_side_effects / total_count * 100 AS concerned_side_effects_pct,
	concerned_efficacy / total_count * 100 AS concerned_efficacy_pct,
	antivax / total_count * 100 AS antivax_pct,
	doctor_has_not_recommended_it / total_count * 100 AS doctor_has_not_recommended_it_pct,
	wait_and_see_if_safe / total_count * 100 AS wait_and_see_if_safe_pct,
	others_need_more / total_count * 100 AS others_need_more_pct,
	concerned_costs / total_count * 100 AS concerned_costs_pct,
	mistrust_covid_vax / total_count * 100 AS mistrust_covid_vax_pct,
	mistrust_govt / total_count * 100 AS mistrust_govt_pct,
	no_need_all / total_count * 100 AS no_need_all_pct,
	no_need_already_had_covid / total_count * 100 AS no_need_already_had_covid_pct,
	no_need_not_high_risk / total_count * 100 AS no_need_not_high_risk_pct,
	no_need_use_mask_instead / total_count * 100 AS no_need_use_mask_instead_pct,
	no_need_covid_not_serious / total_count * 100 AS no_need_covid_not_serious_pct,
	no_need_antivax / total_count * 100 AS no_need_antivax_pct,
	no_need_other / total_count * 100 AS no_need_other_pct,
	no_need_dnr / total_count * 100 AS no_need_dnr_pct,
	other_reason / total_count * 100 AS other_reason_pct,
	did_not_report / total_count * 100 AS did_not_report_pct,

    mistrust,
    mistrust / total_count * 100 AS mistrust_pct,
    misinformed,
    misinformed / total_count * 100 AS misinformed_pct

FROM (
	SELECT
		msa_key,
		SUM(IF(characteristic_id = 35, respondents_count, 0)) AS concerned_side_effects,
		SUM(IF(characteristic_id = 36, respondents_count, 0)) AS concerned_efficacy,
		SUM(IF(characteristic_id = 37, respondents_count, 0)) AS antivax,
		SUM(IF(characteristic_id = 38, respondents_count, 0)) AS doctor_has_not_recommended_it,
		SUM(IF(characteristic_id = 39, respondents_count, 0)) AS wait_and_see_if_safe,
		SUM(IF(characteristic_id = 40, respondents_count, 0)) AS others_need_more,
		SUM(IF(characteristic_id = 41, respondents_count, 0)) AS concerned_costs,
		SUM(IF(characteristic_id = 42, respondents_count, 0)) AS mistrust_covid_vax,
		SUM(IF(characteristic_id = 43, respondents_count, 0)) AS mistrust_govt,
		SUM(IF(characteristic_id = 44, respondents_count, 0)) AS no_need_all,
		SUM(IF(characteristic_id = 45, respondents_count, 0)) AS no_need_already_had_covid,
		SUM(IF(characteristic_id = 46, respondents_count, 0)) AS no_need_not_high_risk,
		SUM(IF(characteristic_id = 47, respondents_count, 0)) AS no_need_use_mask_instead,
		SUM(IF(characteristic_id = 48, respondents_count, 0)) AS no_need_covid_not_serious,
		SUM(IF(characteristic_id = 49, respondents_count, 0)) AS no_need_antivax,
		SUM(IF(characteristic_id = 50, respondents_count, 0)) AS no_need_other,
		SUM(IF(characteristic_id = 51, respondents_count, 0)) AS no_need_dnr,
		SUM(IF(characteristic_id = 52, respondents_count, 0)) AS other_reason,
		SUM(IF(characteristic_id = 53, respondents_count, 0)) AS did_not_report,
		SUM(IF(characteristic_id IN (42, 43), respondents_count, 0)) AS mistrust,
		SUM(IF(characteristic_id IN (48, 49), respondents_count, 0)) AS misinformed,
        SUM(respondents_count) AS total_count
	FROM msa_survey_response
	JOIN dim_characteristic USING(characteristic_key)
	WHERE survey_key IN (SELECT MAX(survey_key) FROM dim_survey)
		AND characteristic_type_key = 7
	GROUP BY
		msa_key
) AS t
JOIN dim_msa USING (msa_key)
;

CREATE VIEW v_state_vaccine_hesitancy_reasons AS
SELECT
	state_key,
	abbrev,
	collection_end_date_key AS date_key,
	characteristic_key,
	label AS characteristic_label,
    CASE WHEN characteristic_key IN (37) THEN "Antivaxx"
		 WHEN characteristic_key IN (42, 43) THEN "Trust issues"
         WHEN characteristic_key IN (36, 41, 48, 49) THEN "Misinformed"
         WHEN characteristic_key IN (35, 38, 39) THEN "Medical"
         WHEN characteristic_key IN (40) THEN "Altruism"
         WHEN characteristic_key IN (45, 46, 47) THEN "CDC Guidelines"
         WHEN characteristic_key IN (50, 51, 52) THEN "Other"
         WHEN characteristic_key IN (53) THEN "Did not report"
         ELSE NULL END AS category,
	SUM(respondents_count) AS respondents_count
FROM state_survey_response
JOIN dim_characteristic USING(characteristic_key)
JOIN dim_state USING (state_key)
JOIN dim_survey USING (survey_key)
WHERE characteristic_type_key = 7
GROUP BY
	state_key, abbrev, collection_end_date_key, characteristic_key, label
;

DROP VIEW v_msa_vaccine_hesitancy_reasons;
CREATE VIEW v_msa_vaccine_hesitancy_reasons AS
SELECT
	collection_end_date_key AS date_key,
	msa_key,
	name AS msa_name,
	characteristic_key,
	label AS characteristic_label,
    CASE WHEN characteristic_key IN (37) THEN "Antivaxx"
		 WHEN characteristic_key IN (42, 43) THEN "Trust issues"
         WHEN characteristic_key IN (36, 41, 48, 49) THEN "Misinformed"
         WHEN characteristic_key IN (35, 38, 39) THEN "Medical"
         WHEN characteristic_key IN (40) THEN "Altruism"
         WHEN characteristic_key IN (45, 46, 47) THEN "CDC Guidelines"
         WHEN characteristic_key IN (50, 51, 52) THEN "Other"
         WHEN characteristic_key IN (53) THEN "Did not report"
         ELSE NULL END AS category,
	SUM(respondents_count) AS respondents_count
FROM msa_survey_response
JOIN dim_characteristic USING(characteristic_key)
JOIN dim_msa USING (msa_key)
JOIN dim_survey USING (survey_key)
WHERE characteristic_type_key = 7
GROUP BY
	msa_key, name, collection_end_date_key, characteristic_key, label
;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
