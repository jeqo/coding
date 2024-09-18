WITH team_countries AS (
	SELECT 
		DISTINCT(code) as team_code,
		country_code,
		discipline,
		events
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
),
paris_gold_medals AS (
	select country_code, count(1) as medals 
	from medals_all 
	where medal_code = 1
	group by country_code 
	order by medals desc
),
medals_gold_diff AS (
	select 
		p.country_code,
		p.medals as paris_medals_total,
		t.gold_medal as tokyo_medals_total,
		p.medals - t.gold_medal as diff
	from paris_gold_medals as p
		join tokyo_medals as t
			on p.country_code = t.country_code
	order by diff desc
),
medals_gold_top5 AS (
	select * from medals_gold_diff limit 5
),
women_teams AS (
	select * from team_countries where events = 'Women''s Team'
)
select m.country_code, m.diff, w.team_code
from women_teams as w 
	join medals_gold_top5 as m 
		on w.country_code = m.country_code
order by m.diff desc, m.country_code, team_code
