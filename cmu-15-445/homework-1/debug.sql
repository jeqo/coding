WITH
	team_countries AS (
		SELECT 
			DISTINCT(code) as team_code, 
			country_code,
			discipline 
		FROM teams
	),
	results_team AS (
		SELECT 
			r."date",
			r.discipline_name,
			t.team_code,
			t.country_code
		FROM results AS r
			JOIN team_countries AS t
				ON r.participant_code = t.team_code
		WHERE
			r.participant_type = 'Team'
			AND r."rank" is not null
	),
	results_ath AS (
		SELECT 
			r."date",
			r.discipline_name,
			a.code,
			a.country_code
		FROM results AS r
			JOIN athletes AS a
				ON r.participant_code = a.code
		WHERE
			r.participant_type = 'Person'
			AND r."rank" is not null
	),
	results_all AS (
		SELECT * FROM results_team 
		UNION ALL
		SELECT * FROM results_ath  
	),
	ranked_countries AS (
		select
			c.code,
			c.country,
			c."GDP ($ per capita)" AS gdp,
			c.population,
			rank() over (
				order by coalesce("GDP ($ per capita)", 0) desc
			) as gdp_rank,
			rank() over (
				order by coalesce(population, 0) desc
			) as population_rank
		from countries as c
		where c."GDP ($ per capita)" != ''
	),
	results_per_country AS (
		SELECT
			r."date",
			r.country_code,
			count(1) AS appearances
		FROM results_team AS r
		GROUP BY r."date", r.country_code
	),
	ranked_results AS (
		SELECT
			"date",
			country_code,
			appearances,
			RANK() OVER (
				PARTITION BY "date"
				ORDER BY appearances DESC
			) AS top_appearances
		FROM results_per_country
	)
SELECT * FROM results_per_country where date = '2024-07-25'  order by appearances desc limit 20;
