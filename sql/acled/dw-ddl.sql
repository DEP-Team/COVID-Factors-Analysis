USE covid_dw;

CREATE TABLE IF NOT EXISTS dim_event_type (
	event_type_key TINYINT NOT NULL AUTO_INCREMENT,
	event_type VARCHAR(25) NOT NULL,
	sub_event_type VARCHAR(25) NOT NULL,
	event_type_slug VARCHAR(25) NOT NULL,
	general_type VARCHAR(25) NOT NULL,
	PRIMARY KEY (event_type_key),
	UNIQUE KEY (event_type_slug),
	INDEX dim_event_type_event_type_key_idx (event_type_key),
	INDEX dim_event_type_event_type_slug_idx (event_type_slug),
	INDEX dim_event_type_event_type_idx (event_type),
	INDEX dim_event_type_sub_event_type_idx (sub_event_type),
	INDEX dim_event_type_general_type_idx (general_type)
);

CREATE TABLE IF NOT EXISTS dim_interaction (
	interaction_key TINYINT NOT NULL AUTO_INCREMENT,
	name VARCHAR(45) NOT NULL,
	description VARCHAR(200) NOT NULL,
	PRIMARY KEY (interaction_key),
	UNIQUE KEY (name),
	INDEX dim_interaction_interaction_key_idx (interaction_key)
);

CREATE TABLE IF NOT EXISTS dim_actor_type (
	actor_type_key INT NOT NULL AUTO_INCREMENT,
	name VARCHAR(20) NOT NULL,
	PRIMARY KEY (actor_type_key),
	UNIQUE KEY (name),
	INDEX dim_actor_type_actor_type_key_idx (actor_type_key)
);

CREATE TABLE IF NOT EXISTS dim_actor (
	actor_key INT NOT NULL AUTO_INCREMENT,
	actor_id INT NOT NULL,
	actor_name VARCHAR(100),
	actor_slug VARCHAR(100),
	source VARCHAR(5),
	PRIMARY KEY (actor_key),
	UNIQUE KEY (actor_slug),
	UNIQUE KEY (source, actor_id),
	INDEX dim_actor_actor_key_idx (actor_key),
	INDEX dim_actor_actor_slug_idx (actor_slug)
);

CREATE TABLE IF NOT EXISTS fact_event (
	event_key INT NOT NULL AUTO_INCREMENT,
	county_key INT NOT NULL,
	date_key INT NOT NULL,
	event_type_key TINYINT NOT NULL,
	interaction_key TINYINT NOT NULL,
	event_id INT NULL,
	ccc_event_id VARCHAR(36) NULL,
	event_id_hash VARCHAR(36) NULL,
	fatalities INT NULL DEFAULT 0,
	arrests_any TINYINT NOT NULL DEFAULT 0,
	injuries_any TINYINT NOT NULL DEFAULT 0,
	property_damage_any TINYINT NOT NULL DEFAULT 0,
	chemical_agents_any TINYINT NOT NULL DEFAULT 0,
	size INT NULL DEFAULT 0,
	size_scale INT NOT NULL DEFAULT 0,
	tags VARCHAR(100) NULL,
	notes VARCHAR(4500) NULL,
	armed_presence TINYINT NOT NULL DEFAULT 0,
	counter_protest TINYINT NOT NULL DEFAULT 0,
	location VARCHAR(500) NULL,
	latitude FLOAT NULL,
	longitude FLOAT NULL,
	geo_precision TINYINT NOT NULL DEFAULT 0,
	time_precision TINYINT NOT NULL DEFAULT 0,
	source VARCHAR(5) NULL,
	source_scale VARCHAR(25) NOT NULL,
	source_count INT NOT NULL DEFAULT 0,
	source_links VARCHAR(2500) NOT NULL,
	PRIMARY KEY (event_key),
	UNIQUE KEY (source, event_id_hash),
	INDEX f_event_ccc_event_id_idx (ccc_event_id),
	INDEX f_event_event_key_idx (event_key),
	INDEX f_event_county_key_idx (county_key),
	INDEX f_event_date_key_idx (date_key),
	INDEX f_event_event_type_key_idx (event_type_key),
	INDEX f_event_interaction_key_idx (interaction_key),
	INDEX f_event_size_scale_idx (size_scale),
	INDEX f_event_armed_presence_idx (armed_presence),
	INDEX fact_event_counter_protest_idx (counter_protest),
	CONSTRAINT fact_event_county_key_fk
		FOREIGN KEY (county_key)
		REFERENCES dim_county (county_key),
	CONSTRAINT fact_event_date_key_fk
		FOREIGN KEY (date_key)
		REFERENCES dim_date (date_key),
	CONSTRAINT fact_event_event_type_key_fk
		FOREIGN KEY (event_type_key)
		REFERENCES dim_event_type (event_type_key),
	CONSTRAINT fact_event_interaction_key_fk
		FOREIGN KEY (interaction_key)
		REFERENCES dim_interaction (interaction_key)
);

CREATE TABLE IF NOT EXISTS event_x_actor (
	event_key INT NOT NULL,
	actor_key INT NOT NULL,
	actor_type_key INT NOT NULL,
	group_num TINYINT NOT NULL,
	affiliation ENUM('primary', 'associated'),
	claims VARCHAR(750) NULL,
	valence INT NULL DEFAULT 0,
	PRIMARY KEY (event_key, actor_key),
	UNIQUE KEY (event_key, actor_key, group_num),
	INDEX x_event_actor_event_key_actor_key_idx (event_key, actor_key),
	INDEX x_event_actor_actor_key_idx (actor_key),
	INDEX x_event_actor_actor_type_key_idx (actor_type_key),
	INDEX x_event_actor_group_idx (group_num),
	INDEX x_event_actor_affiliation_idx (affiliation),
	CONSTRAINT x_event_actor_event_key_fk
		FOREIGN KEY (event_key)
		REFERENCES fact_event (event_key),
	CONSTRAINT x_event_actor_actor_key_fk
		FOREIGN KEY (actor_key)
		REFERENCES dim_actor (actor_key),
	CONSTRAINT x_event_actor_actor_type_key_fk
		FOREIGN KEY (actor_type_key)
		REFERENCES dim_actor_type (actor_type_key)
);

CREATE TABLE IF NOT EXISTS dim_issue (
	issue_key INT NOT NULL AUTO_INCREMENT,
	issue_name VARCHAR(25) NOT NULL,
	issue_slug VARCHAR(25) NOT NULL,
	PRIMARY KEY (issue_key),
	INDEX dim_issue_issue_key_idx (issue_key)
);

CREATE TABLE IF NOT EXISTS dim_protest_type (
	protest_type_key INT NOT NULL AUTO_INCREMENT,
	protest_type_name VARCHAR(100) NOT NULL,
	protest_type_slug VARCHAR(100) NOT NULL,
	PRIMARY KEY (protest_type_key),
	INDEX dim_protest_type_protest_type_key_idx (protest_type_key)
);

CREATE TABLE IF NOT EXISTS event_x_issue (
	event_key INT NOT NULL,
	issue_key INT NOT NULL,
	PRIMARY KEY (event_key, issue_key),
	INDEX event_issue_pk (event_key, issue_key),
	CONSTRAINT x_event_issue_event_key_fk
		FOREIGN KEY (event_key)
		REFERENCES fact_event (event_key),
	CONSTRAINT x_event_issue_issue_key_fk
		FOREIGN KEY (issue_key)
		REFERENCES dim_issue (issue_key)
);

CREATE TABLE IF NOT EXISTS event_x_protest_type (
	event_key INT NOT NULL,
	protest_type_key INT NOT NULL,
	PRIMARY KEY (event_key, protest_type_key),
	INDEX x_event_protest_type_pk (event_key, protest_type_key),
	CONSTRAINT x_event_protest_type_event_key_fk
		FOREIGN KEY (event_key)
		REFERENCES fact_event (event_key),
	CONSTRAINT x_event_protest_type_protest_type_key_fk
		FOREIGN KEY (protest_type_key)
		REFERENCES dim_protest_type (protest_type_key)
);