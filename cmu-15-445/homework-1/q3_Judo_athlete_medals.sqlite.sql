WITH 
	team_countries AS (
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
		FROM medals AS m 
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
	judo_ath_winners(
		country_code, 
		discipline,
		medal_code,
		athlete_code
	) AS (
		SELECT * 
		FROM medals_ath 
		WHERE discipline LIKE ('%Judo%')
	),
	judo_by_team_winners(
		country_code,
		discipline, 
		medal_code, 
		athlete_code
	) AS (
		SELECT 
			m.country_code, 
			m.discipline, 
			m.medal_code, 
			t.athletes_code
		FROM medals_team AS m 
			JOIN teams AS t 
				ON m.team_code = t.code
		WHERE m.discipline LIKE ('%Judo%')
	),
	judo_winners AS (
		SELECT * 
		FROM judo_ath_winners 
		UNION ALL
		SELECT * 
		FROM judo_by_team_winners
	)
SELECT 
	a.name AS ATHLETE_NAME, 
	COUNT(1) AS MEDAL_NUMBER 
FROM judo_winners AS w 
	JOIN athletes AS a 
		ON w.athlete_code = a.code 
GROUP BY a.code 
ORDER BY MEDAL_NUMBER DESC, ATHLETE_NAME
