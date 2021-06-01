USE `covid_dw`;

###Sequence of summary views and summaries / inputs to vaccination rate overview by state### 
#View - State_Overview
CREATE VIEW State_Overview AS
SELECT state_survey_response.state_survey_response_key, dim_survey.week_label, dim_state.name, dim_characteristic_type.label AS type_label, dim_characteristic.label AS char_label, dim_response.choice, state_survey_response.respondents_count
FROM state_survey_response, dim_state, dim_survey, dim_characteristic_type, dim_characteristic, dim_response   
WHERE state_survey_response.survey_key = dim_survey.survey_key
AND state_survey_response.state_key = dim_state.state_key
AND state_survey_response.characteristic_key = dim_characteristic.characteristic_key
AND dim_characteristic.characteristic_type_key = dim_characteristic_type.characteristic_type_key
AND state_survey_response.response_key = dim_response.response_key;

#State detail template (excl. 'intent')
CREATE VIEW State_detail_template AS
SELECT * FROM covid_dw.State_Overview
WHERE name = 'Alabama'
AND week_label = 22
ORDER BY type_label, choice DESC;

#View - Total respondents summary
CREATE VIEW State_total_respondents_summary AS
SELECT week_label, name, SUM(respondents_count) AS sum_of_resp
FROM State_Overview
WHERE type_label = 'Age Group'
GROUP BY week_label, name;

#View - State vaccination counts summary
CREATE VIEW State_vaccination_counts AS
SELECT week_label, name, choice, SUM(respondents_count) AS sum_of_resp
FROM State_Overview
WHERE type_label = 'Age Group'
GROUP BY week_label, name, choice, type_label;

#View - State vaccination rates
CREATE VIEW State_vaccination_rates AS
SELECT State_vaccination_counts.week_label, State_vaccination_counts.name, State_vaccination_counts.choice, State_vaccination_counts.sum_of_resp AS count_cat, State_total_respondents_summary.sum_of_resp AS count_tot
FROM State_vaccination_counts, State_total_respondents_summary
WHERE State_vaccination_counts.week_label = State_total_respondents_summary.week_label
AND State_vaccination_counts.name = State_total_respondents_summary.name;
