USE covid_dw;

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

INSERT INTO event (
	county_key,
	date_key,
	event_type_key,
	interaction_key,
	event_id,
	fatalities,
	size,
	size_scale,
	tags,
	notes,
	armed_presence,
	counter_protest,
	location,
	geo_precision,
	time_precision,
	source,
	source_scale,
	source_count,
	source_table
)
	SELECT
		dim_county.county_key,
		date_id AS date_key,
		event_type_id AS event_type_key,
		interaction_id AS interaction_key,
		event_id,
		fatalities,
		size,
		size_scale,
		tags,
		notes,
		armed_presence,
		counter_protest,
		location,
		geo_precision,
		time_precision,
		source,
		source_scale,
		source_count,
		"acled" AS source_table
	FROM covid.acled_event
	JOIN covid_dw.dim_county USING (county_id)
;

INSERT INTO event_actor (
	event_key,
	actor_key,
	actor_type_key,
	group_num,
	affiliation
)
	SELECT
		event.event_key,
		dim_actor.actor_key,
		actor_type_id AS actor_type_key,
		group_num,
		affiliation
	FROM covid.event_actor
	JOIN covid_dw.event USING (event_id)
	JOIN covid_dw.dim_actor USING (actor_id)
	WHERE event.source_table = "acled"
		AND dim_actor.`source` = "acled"
;