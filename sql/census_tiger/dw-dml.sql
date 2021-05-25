USE covid_dw;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


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
    name
)
	SELECT
		csa_id,
		name
	FROM covid.csa
;

INSERT INTO dim_msa (
	msa_id,
    name,
    type
)
	SELECT
		msa_id,
		name,
		type
	FROM covid.msa
;

INSERT INTO dim_county (
	state_key,
    csa_key,
    msa_key,
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
		dim_msa.msa_key,
		c.county_id,
		c.name,
		c.county_fips,
		c.state_fips,
		c.feature_code,
		c.lsad_code,
		c.land_area,
		c.water_area,
		cm.centrality AS csa_centrality
	FROM covid.county AS c
		JOIN covid_dw.dim_state AS dim_s
			USING(state_fips)
		LEFT JOIN covid.county_msa AS cm
			USING(county_id)
		LEFT JOIN covid_dw.dim_csa AS dim_csa
			USING(csa_id)
		LEFT JOIN covid_dw.dim_msa AS dim_msa
			USING(msa_id)
;