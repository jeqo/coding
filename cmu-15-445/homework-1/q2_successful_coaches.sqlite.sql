WITH team_countries AS (
	SELECT 
		DISTINCT(code) as team_code,
		country_code,
		discipline
	FROM teams
),
medals_ath AS (
	SELECT 
		a.country_code,
		m.discipline,
		m.medal_code,
		a.code 
	FROM 
		medals AS m 
		JOIN athletes AS a 
			ON m.winner_code = a.code
),
medals_team AS (
	SELECT
		t.country_code, 
		t.discipline, 
		m.medal_code, 
		t.team_code 
	FROM medals AS m 
		JOIN team_countries AS t 
			ON m.winner_code = t.team_code
),
medals_all AS (
	SELECT * FROM medals_ath
	UNION ALL 
	SELECT * FROM medals_team
)
SELECT 
	c.name AS COACH_NAME, 
	count(1) AS MEDAL_NUMBER
FROM coaches AS c 
	JOIN medals_all AS m 
		ON c.country_code = m.country_code
		AND c.discipline = m.discipline 
GROUP BY c.name 
ORDER BY MEDAL_NUMBER DESC, c.name;

