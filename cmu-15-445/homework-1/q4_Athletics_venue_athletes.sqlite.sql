WITH
	venues_athletics AS (
		SELECT * 
		FROM venues 
		WHERE disciplines LIKE '%Athletics%'
	),
	athletes_athletics AS (
		SELECT * 
		FROM athletes
		WHERE disciplines LIKE '%Athletics%'
	),
	athletes_teams_athletics AS (
		SELECT a.* 
		FROM athletes AS a
			JOIN teams AS t
				ON a.code = t.athletes_code
		WHERE t.discipline LIKE '%Athletics%'
	),
	athletes_athletics_all AS (
		SELECT * FROM athletes_athletics 
		UNION
		SELECT * FROM athletes_teams_athletics 
	),
	athletes_athletics_country_distance AS (
		SELECT 
			a.*, 
			power(c2.latitude - c1.latitude, 2) + power(c2.longitude - c1.longitude, 2) AS distance
		FROM athletes_athletics_all AS a
			JOIN countries AS c1
			  ON a.country_code = c1.code
			JOIN countries AS c2
			  ON a.nationality_code = c2.code
		WHERE 
			c1.latitude IS NOT NULL
			AND
			c1.longitude IS NOT NULL
			AND
			c2.latitude IS NOT NULL
			AND
			c2.longitude IS NOT NULL
		ORDER BY distance desc
	)
SELECT 
	name AS ATHLETE_NAME, 
	country_code AS REPRESENTED_COUNTRY_CODE, 
	nationality_code NATIONALITY_COUNTRY_CODE, 
	distance
FROM athletes_athletics_country_distance;
