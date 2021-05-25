
/*

earlier sketches


-- clean up cases where ma7d and ma14d are negative
UPDATE `state_cases_daily`
SET positives_ma7d = 0
WHERE positives_ma7d < 0;

UPDATE `state_cases_daily`
SET deaths_ma7d = 0
WHERE deaths_ma7d < 0;

UPDATE `state_cases_daily`
SET positives_ma14d = 0
WHERE positives_ma14d < 0;

UPDATE `state_cases_daily`
SET deaths_ma14d = 0
WHERE deaths_ma14d < 0;

-- positives_ma7d_lag7, deaths_ma7d_lag7
UPDATE `state_cases_daily` c1
JOIN `dim_date` d1 USING (date_key)
JOIN `dim_date` d2 ON d2.date = DATE_SUB(d1.date, INTERVAL 7 DAY)
JOIN `state_cases_daily` c2
	ON c2.state_key = c1.state_key
    AND c2.date_key = d2.date_key
SET c1.positives_ma7d_lag7 = c2.positives_ma7d,
	c1.deaths_ma7d_lag7 = c2.deaths_ma7d;

-- positives_ma7d_lag14, deaths_ma7d_lag14
UPDATE `state_cases_daily` c1
JOIN `dim_date` d1 USING (date_key)
JOIN `dim_date` d2 ON d2.date = DATE_SUB(d1.date, INTERVAL 14 DAY)
JOIN `state_cases_daily` c2
	ON c2.state_key = c1.state_key
    AND c2.date_key = d2.date_key
SET c1.positives_ma7d_lag14 = c2.positives_ma7d,
	c1.deaths_ma7d_lag14 = c2.deaths_ma7d;

-- positives_ma7d_lead7, deaths_ma7d_lead7
UPDATE `state_cases_daily` c1
JOIN `dim_date` d1 USING (date_key)
JOIN `dim_date` d2 ON d2.date = DATE_ADD(d1.date, INTERVAL 7 DAY)
JOIN `state_cases_daily` c2
	ON c2.state_key = c1.state_key
    AND c2.date_key = d2.date_key
SET c1.positives_ma7d_lead7 = c2.positives_ma7d,
	c1.deaths_ma7d_lead7 = c2.deaths_ma7d;

-- positives_ma7d_lead14, deaths_ma7d_lead14
UPDATE `state_cases_daily` c1
JOIN `dim_date` d1 USING (date_key)
JOIN `dim_date` d2 ON d2.date = DATE_ADD(d1.date, INTERVAL 14 DAY)
JOIN `state_cases_daily` c2
	ON c2.state_key = c1.state_key
    AND c2.date_key = d2.date_key
SET c1.positives_ma7d_lead14 = c2.positives_ma7d,
	c1.deaths_ma7d_lead14 = c2.deaths_ma7d;

--
-- csa aggregates
--

INSERT INTO `csa_cases_daily` (
	csa_key,
    date_key,
    positives_new,
    deaths_new,
    positives_total,
    deaths_total,
    positives_ma7d,
    deaths_ma7d,
    positives_ma14d,
    deaths_ma14d
) SELECT
		csa_key,
        date_key,
        positives_new,
        deaths_new,
        positives_total,
        deaths_total,
        AVG(positives_new) OVER(PARTITION BY csa_key ORDER BY date_key
								ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
			AS positives_ma7d,
		AVG(deaths_new) OVER(PARTITION BY csa_key ORDER BY date_key
								ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
			AS deaths_ma7d,
		AVG(positives_new) OVER(PARTITION BY csa_key ORDER BY date_key
								ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
			AS positives_ma14d,
		AVG(deaths_new) OVER(PARTITION BY csa_key ORDER BY date_key
								ROWS BETWEEN 7 PRECEDING AND CURRENT ROW)
			AS deaths_ma14d
	FROM (
		SELECT
    		dim_county.csa_key,
			cc.date_id AS date_key,
			SUM(cc.positives_new) AS positives_new,
			SUM(cc.deaths_new) AS deaths_new,
			SUM(cc.positives_total) AS positives_total,
			SUM(cc.deaths_total) AS deaths_total
		FROM covid.county_cases AS cc
        JOIN dim_county
			USING (county_id)
		WHERE
			dim_county.csa_key IS NOT NULL
		GROUP BY
			csa_key,
            date_key
	) AS t
;

-- clean up cases where ma7d and ma14d are negative
UPDATE `csa_cases_daily`
SET positives_ma7d = 0
WHERE positives_ma7d < 0;

UPDATE `csa_cases_daily`
SET deaths_ma7d = 0
WHERE deaths_ma7d < 0;

UPDATE `csa_cases_daily`
SET positives_ma14d = 0
WHERE positives_ma14d < 0;

UPDATE `csa_cases_daily`
SET deaths_ma14d = 0
WHERE deaths_ma14d < 0;

-- positives_ma7d_lag7, deaths_ma7d_lag7
UPDATE `csa_cases_daily` c1
JOIN `dim_date` d1 USING (date_key)
JOIN `dim_date` d2 ON d2.date = DATE_SUB(d1.date, INTERVAL 7 DAY)
JOIN `csa_cases_daily` c2
	ON c2.csa_key = c1.csa_key
    AND c2.date_key = d2.date_key
SET c1.positives_ma7d_lag7 = c2.positives_ma7d,
	c1.deaths_ma7d_lag7 = c2.deaths_ma7d;

-- positives_ma7d_lag14, deaths_ma7d_lag14
UPDATE `csa_cases_daily` c1
JOIN `dim_date` d1 USING (date_key)
JOIN `dim_date` d2 ON d2.date = DATE_SUB(d1.date, INTERVAL 14 DAY)
JOIN `csa_cases_daily` c2
	ON c2.csa_key = c1.csa_key
    AND c2.date_key = d2.date_key
SET c1.positives_ma7d_lag14 = c2.positives_ma7d,
	c1.deaths_ma7d_lag14 = c2.deaths_ma7d;

-- positives_ma7d_lead7, deaths_ma7d_lead7
UPDATE `csa_cases_daily` c1
JOIN `dim_date` d1 USING (date_key)
JOIN `dim_date` d2 ON d2.date = DATE_ADD(d1.date, INTERVAL 7 DAY)
JOIN `csa_cases_daily` c2
	ON c2.csa_key = c1.csa_key
    AND c2.date_key = d2.date_key
SET c1.positives_ma7d_lead7 = c2.positives_ma7d,
	c1.deaths_ma7d_lead7 = c2.deaths_ma7d;

-- positives_ma7d_lead14, deaths_ma7d_lead14
UPDATE `csa_cases_daily` c1
JOIN `dim_date` d1 USING (date_key)
JOIN `dim_date` d2 ON d2.date = DATE_ADD(d1.date, INTERVAL 14 DAY)
JOIN `csa_cases_daily` c2
	ON c2.csa_key = c1.csa_key
    AND c2.date_key = d2.date_key
SET c1.positives_ma7d_lead14 = c2.positives_ma7d,
	c1.deaths_ma7d_lead14 = c2.deaths_ma7d;

