USE covid_dw;

SET SQL_SAFE_UPDATES = 0;

INSERT INTO dim_event_type (
	event_type_key,
	event_type,
	sub_event_type,
	event_type_slug,
	general_type
)
	SELECT
		event_type_id AS event_type_key,
		event_type,
		sub_event_type,
		event_type_slug,
		general_type
	FROM covid.event_type
;

INSERT INTO dim_interaction (
	interaction_key,
	name,
	description
)
	SELECT
		interaction_id AS interaction_key,
		name,
		description
	FROM covid.interaction
;

INSERT INTO dim_issue (
	issue_key,
	issue_name,
    issue_slug
)
	SELECT
		issue_id AS issue_key,
		issue_name,
        issue_slug
	FROM covid.issue
;

INSERT INTO dim_protest_type (
	protest_type_key,
	protest_type_name,
    protest_type_slug
)
	SELECT
		protest_type_id AS protest_type_key,
		protest_type_name,
        protest_type_slug
	FROM covid.protest_type
;

INSERT INTO dim_actor_type (
	actor_type_key,
	name
)
	SELECT
		actor_type_id AS actor_type_key,
		name
	FROM covid.actor_type
;

INSERT INTO dim_actor (
	actor_id,
	actor_name,
	actor_slug,
	source
)
	SELECT
		actor_id,
		actor_name,
		actor_slug,
		"acled" AS source
	FROM covid.actor
;

INSERT INTO dim_actor (
	actor_id,
	actor_name,
	actor_slug,
	source
)
SELECT
	a1.actor_id,
    a1.actor_name,
    a1.actor_slug,
    "ccc" AS source
FROM covid.ccc_actor AS a1
WHERE a1.actor_slug NOT IN (
	SELECT actor_slug FROM covid.actor AS a2
)
;

INSERT INTO fact_event (
	county_key,
	date_key,
	event_type_key,
	interaction_key,
	event_id,
    event_id_hash,
	fatalities,
	size,
	size_scale,
	tags,
	notes,
	armed_presence,
	counter_protest,
	location,
	latitude,
	longitude,
	geo_precision,
	time_precision,
	source,
	source_scale,
	source_count,
	source_links
)
	SELECT
		dim_county.county_key,
		date_id AS date_key,
		event_type_id AS event_type_key,
		interaction_id AS interaction_key,
		event_id,
		CAST(event_id AS CHAR(10)) AS event_id_hash,
		fatalities,
		size,
		size_scale,
		tags,
		notes,
		armed_presence,
		counter_protest,
		location,
		latitude,
		longitude,
		geo_precision,
		time_precision,
		"acled" AS source,
		source_scale,
		source_count,
		source AS source_links
	FROM covid.acled_event
	JOIN covid_dw.dim_county USING (county_id)
;

UPDATE fact_event
JOIN covid.acled_event
	ON acled_event.event_id = fact_event.event_id
JOIN covid.ccc_event
	ON acled_event.date_id = ccc_event.date_id
	AND acled_event.county_id = ccc_event.county_id
	AND acled_event.source_ccc = 1
SET	fact_event.size = ccc_event.size,
	fact_event.size_scale = ccc_event.size_scale,
	fact_event.location = ccc_event.location_detail,
    fact_event.arrests_any = ccc_event.arrests_any,
	fact_event.injuries_any = CAST((injuries_crowd_any + injuries_police_any) > 0 AS UNSIGNED),
	fact_event.property_damage_any = ccc_event.property_damage_any,
	fact_event.chemical_agents_any = IFNULL(ccc_event.chemical_agents, 0),
	fact_event.source = "merge",
    fact_event.ccc_event_id = ccc_event.event_id
;

INSERT INTO fact_event (
	county_key,
	date_key,
	event_type_key,
	interaction_key,
	ccc_event_id,
    event_id_hash,
	size,
	size_scale,
	notes,
	counter_protest,
	location,
	latitude,
	longitude,
    arrests_any,
    injuries_any,
    property_damage_any,
    chemical_agents_any,
	source,
	source_count,
    source_scale,
	source_links
)
	SELECT
		dim_county.county_key,
		ccc_event.date_id AS date_key,
		ccc_event.event_type_id AS event_type_key,
		ccc_event.interaction_id AS interaction_key,
		ccc_event.event_Id AS ccc_event_id,
        ccc_event.event_id AS event_id_hash,
		ccc_event.size,
		ccc_event.size_scale,
		SUBSTRING(ccc_event.notes, 0, 4500) AS notes,
		ccc_event.counter_protest,
		ccc_event.location_detail AS location,
		latitude,
		longitude,
		IF(ccc_event.arrests_any, 1, 0) AS arrests_any,
		CAST((injuries_crowd_any + injuries_police_any) > 0 AS UNSIGNED) injuries_any,
        IF(ccc_event.property_damage_any, 1, 0) AS property_damage_any,
        IF(ccc_event.chemical_agents, 1, 0) AS chemical_agents_any,
		"ccc" AS source,
		ccc_event.source_count,
        "" AS source_scale,
		ccc_event.source AS source_links
	FROM covid.ccc_event
	JOIN covid_dw.dim_county USING (county_id)
    WHERE event_id NOT IN (
			SELECT ccc_event_id FROM fact_event WHERE ccc_event_id IS NOT NULL
		)
    ;

INSERT INTO event_x_actor (
	event_key,
	actor_key,
	actor_type_key,
	group_num,
	affiliation
)
	SELECT
		fact_event.event_key,
		dim_actor.actor_key,
		actor_type_id AS actor_type_key,
		group_num,
		affiliation
	FROM covid.event_actor
	JOIN covid_dw.fact_event USING (event_id)
	JOIN covid_dw.dim_actor USING (actor_id)
	WHERE fact_event.source = "acled"
		AND dim_actor.`source` = "acled"
;

INSERT INTO event_x_actor (
	event_key,
	actor_key,
	actor_type_key,
	group_num,
	affiliation,
    claims,
    valence
)
	SELECT
		fact_event.event_key,
		dim_actor.actor_key,
		actor_type_id AS actor_type_key,
		ccc_event_actor.group_num,
        "primary" AS affiliation,
        ccc_event_actor.claims,
        ccc_event_actor.valence
	FROM covid.ccc_event_actor
	JOIN covid_dw.fact_event ON fact_event.ccc_event_id = ccc_event_actor.event_id
    JOIN covid.ccc_actor USING (actor_id)
	JOIN covid_dw.dim_actor ON dim_actor.actor_slug = ccc_actor.actor_slug
	WHERE fact_event.source IN ("merge", "ccc")
	ON DUPLICATE KEY UPDATE event_x_actor.claims = ccc_event_actor.claims,
		event_x_actor.valence = ccc_event_actor.valence;
;

INSERT INTO event_x_issue (
	event_key,
	issue_key
)
	SELECT
		fact_event.event_key,
		dim_issue.issue_key
	FROM covid.ccc_event_issue
	JOIN covid_dw.fact_event ON fact_event.ccc_event_id = ccc_event_issue.event_id
	JOIN covid_dw.dim_issue ON dim_issue.issue_key = ccc_event_issue.issue_id
;

INSERT INTO event_x_protest_type (
	event_key,
	protest_type_key
)
	SELECT
		fact_event.event_key,
		dim_protest_type.protest_type_key
	FROM covid.ccc_event_protest_type
	JOIN covid_dw.fact_event ON fact_event.ccc_event_id = ccc_event_protest_type.event_id
	JOIN covid_dw.dim_protest_type ON dim_protest_type.protest_type_key = ccc_event_protest_type.protest_type_id
;

INSERT INTO capitol_seige_arrests (
	county_key,
    arrests
)
	SELECT
        county_key,
        arrests
	FROM covid.capitol_seige_arrests
	JOIN dim_county
		ON dim_county.county_id = capitol_seige_arrests.county_fips
;