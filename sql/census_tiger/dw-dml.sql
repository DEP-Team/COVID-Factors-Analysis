
USE covid_dw;

INSERT INTO dim_state (
    state_id,
    name,
    abbrev,
    state_fips,
    feature_code,
    lsad_code,
    land_area,
    water_area
)
SELECT
	state_id,
	name,
	abbrev,
	state_fips,
	feature_code,
	lsad_code,
	land_area,
	water_area
FROM covid.state
;

INSERT INTO dim_csa (
	csa_id,
    name,
    type
)
SELECT
	csa_id,
    name,
    type
FROM covid.csa
;

INSERT INTO dim_county (
	state_key,
    csa_key,
    county_id,
    name,
    county_fips,
    state_fips,
    feature_code,
    lsad_code,
    land_area,
    water_area,
    csa_centrality
)
SELECT
	dim_s.state_key,
    dim_csa.csa_key,
    c.county_id,
    c.name,
    c.county_fips,
    c.state_fips,
    c.feature_code,
    c.lsad_code,
    c.land_area,
    c.water_area,
	cc.centrality AS csa_centrality
FROM covid.county AS c
	JOIN covid_dw.dim_state AS dim_s
		USING(state_fips)
	LEFT JOIN covid.county_csa AS cc
		USING(county_id)
	LEFT JOIN covid_dw.dim_csa AS dim_csa
		USING(csa_id)
;