# Homework 1

## Q1
The purpose of this query is to make sure that the formatting of your output matches exactly the formatting of our auto-grading script.

Details: List all medal types in alphabetical order.

```
select distinct(name) from medal_info order by name;
```
Result:
```
Bronze Medal
Gold Medal
Silver Medal
```

## Q2

Find all successful coaches who have won at least one medal. List them in descending order by medal number, then by name alphabetically.

Details: A medal is credited to a coach if it shares the same country and discipline with the coach, regardless of the gender or event. Consider to use winner_code of one medal to decide its country.

```
COACH_NAME|MEDAL_NUMBER
```

```
BRECKENRIDGE Grant|9
```


## Q3

Find all athletes in Judo discipline, and also list the number of medals they have won.
Sort output in descending order by medal number first, then by name alphabetically. 

Details: The medals counted do not have to be from the Judo discipline, and also be sure to include any medals won as part of a team.
If an athlete doesn't appear in the athletes table, please ignore him/her.
Assume that if a team participates in a competition, all team members are competing.

## Q4

For all venues that have hosted Athletics discipline competitions, list all athletes who have competed at these venues, and sort them by the distance from their nationality country to the country they represented in descending order, then by name alphabetically.

Details: The athletes can have any discipline and can compete as a team member or an individual in these venues. The distance between two countries is calculated as the sum square of the difference between their latitudes and longitudes. Only output athletes who have valid information. (i.e., the athletes appear in the athletes table and have non-null latitudes and longitudes for both countries.) Assume that if a team participates in a competition, all team members are competing.

## Q5

For each day, find the country with the highest number of appearances in the top 5 ranks (inclusive) of that day. For these countries, also list their population rank and GDP rank. Sort the output by date in ascending order.

Hints: Use the result table, and use the participant_code to get the corresponding country. If you cannot get the country information for a record in the result table, ignore that record.

Details: When counting appearances, only consider records from the results table where rank is not null. Exclude days where all rank values are null from the output. In case of a tie in the number of appearances, select the country that comes first alphabetically. Keep the original format of the date. Also, DON'T remove duplications from results table when counting appearances. (see Important Clarifications section).

## Q6

List the five countries with the greatest improvement in the number of gold medals compared to the Tokyo Olympics. For each of these five countries, list all their all-female teams. Sort the output first by the increased number of gold medals in descending order, then by country code alphabetically, and last by team code alphabetically.

Details: When calculating all-female teams, if the athletes_code in a record from the teams table is not found in the athletes table, please ignore this record as if it doesn't exist.

Hints: You might find Lateral Joins in DuckDB useful: find out the 5 countries with largest progress first, and then use lateral join to find their all-female reams.

