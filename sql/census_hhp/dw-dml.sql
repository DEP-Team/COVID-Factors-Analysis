USE covid_dw;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


INSERT INTO dim_characteristic_type (
	characteristic_type_id,
    label
)
	SELECT
		characteristic_type_id,
        label
	FROM
		covid.characteristic_type
;

INSERT INTO dim_characteristic (
	characteristic_type_key,
    characteristic_id,
    label
)
	SELECT
		dim_characteristic_type.characteristic_type_key,
        characteristic_id,
        characteristic.label
	FROM
		covid.characteristic
        JOIN dim_characteristic_type USING (characteristic_type_id)
;

INSERT INTO dim_response (
    response_id,
    question_id,
    question_table,
    question_label,
    choice,
    subchoice
)
	SELECT
		response.response_id,
        response.question_id,
        question.table,
        question.label,
        response.choice,
        response.subchoice
	FROM covid.response
		JOIN covid.question USING (question_id)
;

INSERT INTO dim_survey (
	collection_start_date_key,
    collection_end_date_key,
    published_date_key,
    survey_id,
    week_label
)
	SELECT
		collection_start_date_id AS collection_start_date_key,
        collection_end_date_id AS collection_end_date_key,
		published_date_id AS published_date_key,
        survey_id,
        week_label
	FROM covid.survey
;

INSERT INTO `us_survey_response` (
  `survey_key`,
  `response_key`,
  `characteristic_key`,
  `survey_response_id`,
  `respondents_count`
)
	SELECT
		dim_survey.survey_key,
        dim_response.response_key,
        dim_characteristic.characteristic_key,
        survey_response_id,
        respondents_count
	FROM covid.survey_response
		JOIN covid.region USING (region_id)
        JOIN dim_response USING (response_id)
        JOIN dim_survey USING (survey_id)
        JOIN dim_characteristic USING (characteristic_id)
	WHERE region.type = "national"
		AND region.fips_code LIKE "US%"
;

INSERT INTO `state_survey_response` (
  `state_key`,
  `survey_key`,
  `response_key`,
  `characteristic_key`,
  `survey_response_id`,
  `respondents_count`
)
	SELECT
		dim_state.state_key,
		dim_survey.survey_key,
        dim_response.response_key,
        dim_characteristic.characteristic_key,
        survey_response_id,
        respondents_count
	FROM covid.survey_response
		JOIN covid.region USING (region_id)
		JOIN dim_state ON region.fips_code LIKE CONCAT(dim_state.state_fips, '%')
        JOIN dim_response USING (response_id)
        JOIN dim_survey USING (survey_id)
        JOIN dim_characteristic USING (characteristic_id)
	WHERE region.type = "state"
;

INSERT INTO `msa_survey_response` (
  `msa_key`,
  `survey_key`,
  `response_key`,
  `characteristic_key`,
  `survey_response_id`,
  `respondents_count`
)
	SELECT
		dim_msa.msa_key,
		dim_survey.survey_key,
        dim_response.response_key,
        dim_characteristic.characteristic_key,
        survey_response_id,
        respondents_count
	FROM covid.survey_response
		JOIN covid.region USING (region_id)
		JOIN dim_msa ON region.fips_code LIKE CONCAT(dim_msa.msa_id, '%')
        JOIN dim_response USING (response_id)
        JOIN dim_survey USING (survey_id)
        JOIN dim_characteristic USING (characteristic_id)
	WHERE region.type = "msa"
;

-- @TODO: us_vaccination
-- @TODO: us_vaccination_by_characteristic
-- @TODO: state_vaccination
-- @TODO: state_vaccination_by_charactistic
-- @TODO: msa_vaccination
-- @TODO: msa_vaccination_by_characteristic

