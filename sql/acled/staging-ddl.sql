USE covid;

CREATE TABLE IF NOT EXISTS event_type (
	event_type_id TINYINT NOT NULL AUTO_INCREMENT,
	event_type VARCHAR(25) NOT NULL,
	sub_event_type VARCHAR(25) NOT NULL,
	event_type_slug VARCHAR(25) NOT NULL,
	general_type VARCHAR(25) NOT NULL,
	PRIMARY KEY (event_type_id),
	UNIQUE KEY (event_type_slug),
	INDEX event_type_event_type_id_idx (event_type_id),
	INDEX event_type_event_type_slug_idx (event_type_slug),
	INDEX event_type_event_type_idx (event_type),
	INDEX event_type_sub_event_type_idx (sub_event_type),
	INDEX event_type_general_type_idx (general_type)
);

CREATE TABLE IF NOT EXISTS interaction (
	interaction_id TINYINT NOT NULL AUTO_INCREMENT,
	name VARCHAR(45) NOT NULL,
	description VARCHAR(200) NOT NULL,
	PRIMARY KEY (interaction_id),
	UNIQUE KEY (name),
	INDEX interaction_interaction_id_idx (interaction_id)
);

CREATE TABLE IF NOT EXISTS actor_type (
	actor_type_id TINYINT NOT NULL AUTO_INCREMENT,
	name VARCHAR(20) NOT NULL,
	PRIMARY KEY (actor_type_id),
	UNIQUE KEY (name),
	INDEX actor_type_actor_type_id_idx (actor_type_id)
);

CREATE TABLE IF NOT EXISTS actor (
	actor_id INT NOT NULL AUTO_INCREMENT,
	actor_name VARCHAR(100),
	actor_slug VARCHAR(100),
	PRIMARY KEY (actor_id),
	UNIQUE KEY (actor_slug),
	INDEX actor_actor_id_idx (actor_id),
	INDEX actor_actor_slug_idx (actor_slug)
);

CREATE TABLE IF NOT EXISTS acled_event (
	event_id INT NOT NULL,
	county_id VARCHAR(5) NOT NULL,
	date_id INT NOT NULL,
	event_type_id TINYINT NOT NULL,
	interaction_id TINYINT NOT NULL,
	fatalities INT NULL DEFAULT 0,
	size INT NULL DEFAULT 0,
	size_scale INT NOT NULL DEFAULT 0,
	tags VARCHAR(100) NULL,
	notes VARCHAR(4500) NULL,
	armed_presence TINYINT NOT NULL DEFAULT 0,
	counter_protest TINYINT NOT NULL DEFAULT 0,
	location VARCHAR(100) NULL,
	geo_precision TINYINT NOT NULL DEFAULT 0,
	time_precision TINYINT NOT NULL DEFAULT 0,
	source VARCHAR(255) NULL,
	source_scale VARCHAR(25) NOT NULL,
	source_count INT NOT NULL DEFAULT 0,
	source_ccc TINYINT NOT NULL DEFAULT 0,
	PRIMARY KEY (event_id),
	INDEX acled_event_event_id_idx (event_id),
	INDEX acled_event_county_id_idx (county_id),
	INDEX acled_event_date_id_idx (date_id),
	INDEX acled_event_event_type_id_idx (event_type_id),
	INDEX acled_event_interaction_id_idx (interaction_id),
	INDEX acled_event_size_scale_idx (size_scale),
	INDEX acled_event_armed_presence_idx (armed_presence),
	INDEX acled_event_counter_protest_idx (counter_protest),
	INDEX acled_event_source_ccc_idx (source_ccc),
	CONSTRAINT acled_event_county_id_fk
		FOREIGN KEY (county_id)
		REFERENCES county (county_id),
	CONSTRAINT acled_event_date_id_fk
		FOREIGN KEY (date_id)
		REFERENCES `date` (date_id),
	CONSTRAINT `acled_event_event_type_id_fk`
		FOREIGN KEY (event_type_id)
		REFERENCES event_type (event_type_id),
	CONSTRAINT `acled_event_interaction_id_fk`
		FOREIGN KEY (interaction_id)
		REFERENCES interaction (interaction_id)
);

CREATE TABLE IF NOT EXISTS event_actor (
	event_id INT NOT NULL,
	actor_id INT NOT NULL,
	actor_type_id TINYINT NOT NULL,
	group_num TINYINT NOT NULL,
	affiliation ENUM('primary', 'associated'),
	PRIMARY KEY (event_id, actor_id),
	UNIQUE KEY (event_id, actor_id, group_num),
	INDEX event_actor_event_id_actor_id_idx (event_id, actor_id),
	INDEX event_actor_actor_id_idx (actor_id),
	INDEX event_actor_actor_type_id_idx (actor_type_id),
	INDEX event_actor_group_idx (group_num),
	INDEX event_actor_affiliation_idx (affiliation),
	CONSTRAINT event_actor_event_id_fk
		FOREIGN KEY (event_id)
		REFERENCES acled_event (event_id),
	CONSTRAINT event_actor_actor_id_fk
		FOREIGN KEY (actor_id)
		REFERENCES actor (actor_id),
	CONSTRAINT event_actor_actor_type_id_fk
		FOREIGN KEY (actor_type_id)
		REFERENCES actor_type (actor_type_id)
);

--
-- Crowd Counting Consortium
--

CREATE TABLE IF NOT EXISTS ccc_actor (
	actor_id INT NOT NULL AUTO_INCREMENT,
	actor_name VARCHAR(500),
	actor_slug VARCHAR(500),
	PRIMARY KEY (actor_id),
	INDEX ccc_actor_actor_id_idx (actor_id),
	INDEX ccc_actor_actor_slug_idx (actor_slug)
);

CREATE TABLE IF NOT EXISTS ccc_event (
	event_id VARCHAR(36) NOT NULL,
	county_id VARCHAR(5) NOT NULL,
	date_id INT NOT NULL,
	event_type_id TINYINT NOT NULL,
	interaction_id TINYINT NOT NULL,
	size INT NULL DEFAULT 0,
	size_scale INT NOT NULL DEFAULT 0,
	notes VARCHAR(5500) NULL,
	counter_protest TINYINT NULL DEFAULT 0,
	location_detail VARCHAR(500) NULL,
	macroevent VARCHAR(255) NULL,
	arrests VARCHAR(100) NULL,
	arrests_any INT NULL DEFAULT 0,
	injuries_crowd VARCHAR(50) NULL,
	injuries_crowd_any INT NULL DEFAULT 0,
	injuries_police VARCHAR(50) NULL,
	injuries_police_any INT NULL DEFAULT 0,
	property_damage VARCHAR(200) NULL,
	property_damage_any INT NULL DEFAULT 0,
	chemical_agents INT NULL DEFAULT 0,
	source VARCHAR(2500) NULL,
	source_count INT NOT NULL DEFAULT 0,
	PRIMARY KEY (event_id),
	INDEX ccc_event_event_id_idx (event_id),
	INDEX ccc_event_county_id_idx (county_id),
	INDEX ccc_event_date_id_idx (date_id),
	INDEX ccc_event_event_type_id_idx (event_type_id),
	INDEX ccc_event_interaction_id_idx (interaction_id),
	INDEX ccc_event_size_scale_idx (size_scale),
	CONSTRAINT ccc_event_county_id_fk
		FOREIGN KEY (county_id)
		REFERENCES county (county_id),
	CONSTRAINT ccc_event_date_id_fk
		FOREIGN KEY (date_id)
		REFERENCES `date` (date_id),
	CONSTRAINT `ccc_event_event_type_id_fk`
		FOREIGN KEY (event_type_id)
		REFERENCES event_type (event_type_id),
	CONSTRAINT `ccc_event_interaction_id_fk`
		FOREIGN KEY (interaction_id)
		REFERENCES interaction (interaction_id)
);

CREATE TABLE IF NOT EXISTS ccc_event_actor (
	event_id VARCHAR(36) NOT NULL,
	actor_id INT NOT NULL,
	actor_type_id TINYINT NOT NULL,
	group_num TINYINT NOT NULL,
	claims VARCHAR(750) NULL,
	valence INT NOT NULL DEFAULT 0,
	PRIMARY KEY (event_id, actor_id, group_num),
	INDEX ccc_event_actor_event_id_actor_id_idx (event_id, actor_id),
	INDEX ccc_event_actor_actor_id_idx (actor_id),
	INDEX ccc_event_actor_actor_type_id_idx (actor_type_id),
	INDEX ccc_event_actor_group_idx (group_num),
	CONSTRAINT ccc_event_actor_event_id_fk
		FOREIGN KEY (event_id)
		REFERENCES ccc_event (event_id),
	CONSTRAINT ccc_event_actor_actor_id_fk
		FOREIGN KEY (actor_id)
		REFERENCES ccc_actor (actor_id),
	CONSTRAINT ccc_event_actor_actor_type_id_fk
		FOREIGN KEY (actor_type_id)
		REFERENCES actor_type (actor_type_id)
);

CREATE TABLE IF NOT EXISTS issue (
	issue_id INT NOT NULL AUTO_INCREMENT,
	issue_name VARCHAR(25) NOT NULL,
	issue_slug VARCHAR(25) NOT NULL,
	PRIMARY KEY (issue_id),
	INDEX issue_issue_id_idx (issue_id)
);

CREATE TABLE IF NOT EXISTS protest_type (
	protest_type_id INT NOT NULL AUTO_INCREMENT,
	protest_type_name VARCHAR(100) NOT NULL,
	protest_type_slug VARCHAR(100) NOT NULL,
	PRIMARY KEY (protest_type_id),
	INDEX protest_type_protest_type_id_idx (protest_type_id)
);

CREATE TABLE IF NOT EXISTS ccc_event_issue (
	event_id VARCHAR(36) NOT NULL,
	issue_id INT NOT NULL,
	PRIMARY KEY (event_id, issue_id),
	INDEX event_issue_pk (event_id, issue_id),
	CONSTRAINT ccc_event_issue_event_id_fk
		FOREIGN KEY (event_id)
		REFERENCES ccc_event (event_id),
	CONSTRAINT ccc_event_issue_issue_id_fk
		FOREIGN KEY (issue_id)
		REFERENCES issue (issue_id)
);

CREATE TABLE IF NOT EXISTS ccc_event_protest_type (
	event_id VARCHAR(36) NOT NULL,
	protest_type_id INT NOT NULL,
	PRIMARY KEY (event_id, protest_type_id),
	INDEX event_protest_type_pk (event_id, protest_type_id),
	CONSTRAINT ccc_event_protest_type_event_id_fk
		FOREIGN KEY (event_id)
		REFERENCES ccc_event (event_id),
	CONSTRAINT ccc_event_protest_type_protest_type_id_fk
		FOREIGN KEY (protest_type_id)
		REFERENCES protest_type (protest_type_id)
);
