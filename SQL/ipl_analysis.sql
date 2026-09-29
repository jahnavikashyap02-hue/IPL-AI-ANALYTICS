 /*
===========================================================
IPL PERFORMANCE & STRATEGY ANALYTICS
SQL ANALYTICS
===========================================================

Project:
IPL Performance & Strategy Analytics using
Python, SQL, Power BI, XGBoost & GenAI

Purpose:
Analyze IPL match and ball-by-ball data to identify
team, player, venue and strategic performance trends.

SQL Topics:
- Aggregation
- GROUP BY
- HAVING
- JOIN
- CASE WHEN
- UNION ALL
- Subqueries
- Business KPI analysis

===========================================================
*/
/*
===========================================================
ANALYTICS QUESTIONS
===========================================================

1. How many matches are in the dataset?
2. How many matches were played in each season?
3. Which teams have the most wins?
4. Which venues hosted the most matches?
5. Who are the top run scorers?
6. Who hit the most sixes?
7. Who hit the most fours?
8. Who took the most wickets?
9. Which batters have the highest strike rate?
10. Which teams scored the most runs?
11. Which teams performed best in the powerplay?
12. Which teams performed best in death overs?
13. How have total runs changed by season?
14. What is the average first-innings score?
15. Is batting first or chasing more successful?
16. How often does the toss winner also win the match?
17. Which teams have the highest win percentage?
18. Which venues have higher average first-innings scores?
19. Which players show more consistent scoring?

===========================================================
*/
/*
===========================================================
IPL PERFORMANCE & STRATEGY ANALYTICS
===========================================================
*/


-- =========================================================
-- SECTION 1: MATCH & SEASON ANALYSIS
-- =========================================================


-- Q1 Total matches played across all seasons
SELECT COUNT(*) AS total_matches FROM matches;

-- Q2 Total runs scored across all seasons
SELECT SUM(total_runs) AS total_runs_scored FROM deliveries;

-- Q3 Total wickets taken across all seasons
SELECT COUNT(*) AS total_wickets 
FROM deliveries 
WHERE is_wicket NOT IN ('0', '') 
  AND is_wicket IS NOT NULL 
  AND dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field');

-- Q4 Season-wise match count
SELECT season, COUNT(*) AS matches_count 
FROM matches 
GROUP BY season 
ORDER BY season;

-- Q5 Season-wise total runs scored
SELECT 
    m.season, 
    SUM(d.total_runs) AS total_runs
FROM matches m
JOIN deliveries d ON m.id = d.match_id
GROUP BY m.season
ORDER BY m.season;

-- Q6 Average first innings score per season
SELECT 
    m.season,
    ROUND(AVG(first_inn.score), 2) AS avg_first_innings_score
FROM matches m
JOIN (
    SELECT match_id, SUM(total_runs) AS score 
    FROM deliveries 
    WHERE inning = 1 
    GROUP BY match_id
) AS first_inn ON m.id = first_inn.match_id
GROUP BY m.season
ORDER BY m.season;


-- =========================================================
-- SECTION 2: TEAM ANALYSIS
-- =========================================================
-- Q1 Team wins
SELECT 
    winner AS team, 
    COUNT(*) AS total_wins 
FROM matches 
WHERE winner IS NOT NULL AND winner != ''
GROUP BY winner 
ORDER BY total_wins DESC;

-- Q2 Matches played
SELECT 
    team, 
    COUNT(*) AS matches_played 
FROM (
    SELECT team1 AS team FROM matches
    UNION ALL
    SELECT team2 AS team FROM matches
) AS combined_teams
WHERE team IS NOT NULL AND team != ''
GROUP BY team 
ORDER BY matches_played DESC;

-- Q3 Team win percentage
WITH team_matches AS (
    SELECT team, COUNT(*) AS played FROM (
        SELECT team1 AS team FROM matches
        UNION ALL
        SELECT team2 AS team FROM matches
    ) AS t WHERE team IS NOT NULL AND team != '' GROUP BY team
),
team_wins AS (
    SELECT winner AS team, COUNT(*) AS wins 
    FROM matches 
    WHERE winner IS NOT NULL AND winner != '' 
    GROUP BY winner
)
SELECT 
    tm.team,
    tm.played,
    COALESCE(tw.wins, 0) AS wins,
    ROUND((COALESCE(tw.wins, 0) * 100.0 / tm.played), 2) AS win_percentage
FROM team_matches tm
LEFT JOIN team_wins tw ON tm.team = tw.team
ORDER BY win_percentage DESC;

-- Q4 Team total runs
SELECT 
    batting_team, 
    SUM(total_runs) AS total_runs 
FROM deliveries 
GROUP BY batting_team 
ORDER BY total_runs DESC;

-- Q5 Powerplay performance
SELECT 
    batting_team, 
    SUM(total_runs) AS powerplay_runs,
    COUNT(CASE WHEN is_wicket NOT IN ('0', '') AND is_wicket IS NOT NULL THEN 1 END) AS powerplay_wickets
FROM deliveries 
WHERE over_no <= 6 
GROUP BY batting_team 
ORDER BY powerplay_runs DESC;

-- Q6 Death-over performance
SELECT 
    batting_team, 
    SUM(total_runs) AS death_runs,
    COUNT(CASE WHEN is_wicket NOT IN ('0', '') AND is_wicket IS NOT NULL THEN 1 END) AS death_wickets
FROM deliveries 
WHERE over_no >= 16 
GROUP BY batting_team 
ORDER BY death_runs DESC;


-- =========================================================
-- SECTION 3: PLAYER ANALYSIS
-- =========================================================

-- Q1 Top run scorers
SELECT 
    batter, 
    SUM(batsman_runs) AS total_runs 
FROM deliveries 
GROUP BY batter 
ORDER BY total_runs DESC 
LIMIT 10;

-- Q2 Top six hitters
SELECT 
    batter, 
    COUNT(*) AS total_sixes 
FROM deliveries 
WHERE batsman_runs = 6 
GROUP BY batter 
ORDER BY total_sixes DESC 
LIMIT 10;

-- Q3 Top four hitters
SELECT 
    batter, 
    COUNT(*) AS total_fours 
FROM deliveries 
WHERE batsman_runs = 4 
GROUP BY batter 
ORDER BY total_fours DESC 
LIMIT 10;

-- Q4 Strike rate
SELECT 
    batter, 
    SUM(batsman_runs) AS total_runs, 
    COUNT(ball) AS balls_faced,
    ROUND((SUM(batsman_runs) * 100.0 / COUNT(ball)), 2) AS strike_rate
FROM deliveries
GROUP BY batter
HAVING total_runs >= 500
ORDER BY strike_rate DESC
LIMIT 10;

-- Q5 Top wicket takers
SELECT 
    bowler, 
    COUNT(*) AS total_wickets 
FROM deliveries 
WHERE is_wicket NOT IN ('0', '') 
  AND is_wicket IS NOT NULL 
  AND dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
GROUP BY bowler 
ORDER BY total_wickets DESC 
LIMIT 10;

-- Q6 Bowling economy
SELECT 
    bowler, 
    SUM(total_runs) AS runs_conceded, 
    COUNT(ball) AS total_balls,
    ROUND((SUM(total_runs) / (COUNT(ball) / 6.0)), 2) AS economy_rate
FROM deliveries
GROUP BY bowler
HAVING total_balls >= 250
ORDER BY economy_rate ASC
LIMIT 10;


-- =========================================================
-- SECTION 4: STRATEGY ANALYSIS
-- =========================================================

-- Q1 Impact of winning the toss on match outcome (Toss Win % vs Match Win %)
SELECT 
    toss_decision,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS toss_and_match_wins,
    ROUND(SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS win_rate_percentage
FROM matches
WHERE toss_decision IS NOT NULL AND toss_decision != ''
GROUP BY toss_decision;

-- Q2 Batting First vs Batting Second success rate
SELECT 
    result,
    COUNT(*) AS total_wins,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM matches WHERE result IN ('runs', 'wickets')), 2) AS percentage
FROM matches
WHERE result IN ('runs', 'wickets')
GROUP BY result;

-- Q3 Bowling style strategy vs Phase efficiency (Powerplay vs Death overs)
SELECT 
    CASE 
        WHEN over_no <= 6 THEN 'Powerplay (1-6)'
        WHEN over_no BETWEEN 7 AND 15 THEN 'Middle Overs (7-15)'
        ELSE 'Death Overs (16-20)'
    END AS match_phase,
    SUM(total_runs) AS total_runs_conceded,
    COUNT(CASE WHEN is_wicket NOT IN ('0', '') AND is_wicket IS NOT NULL THEN 1 END) AS wickets_taken,
    ROUND(SUM(total_runs) / (COUNT(ball) / 6.0), 2) AS phase_economy_rate
FROM deliveries
GROUP BY match_phase
ORDER BY phase_economy_rate ASC;

-- Q4 Boundary reliance strategy by team (Percentage of runs from 4s and 6s)
SELECT 
    batting_team,
    SUM(total_runs) AS total_runs,
    SUM(CASE WHEN batsman_runs IN (4, 6) THEN batsman_runs ELSE 0 END) AS boundary_runs,
    ROUND(SUM(CASE WHEN batsman_runs IN (4, 6) THEN batsman_runs ELSE 0 END) * 100.0 / SUM(total_runs), 2) AS boundary_run_percentage
FROM deliveries
GROUP BY batting_team
ORDER BY boundary_run_percentage DESC;

-- Q5 Dot ball percentage by bowling team (Pressure creation strategy)
SELECT 
    bowling_team,
    COUNT(*) AS total_balls,
    SUM(CASE WHEN total_runs = 0 THEN 1 ELSE 0 END) AS dot_balls,
    ROUND(SUM(CASE WHEN total_runs = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS dot_ball_percentage
FROM deliveries
GROUP BY bowling_team
ORDER BY dot_ball_percentage DESC;


-- =========================================================
-- SECTION 5: VENUE ANALYSIS
-- =========================================================

-- Q1 Toss decision distribution (Bat vs Field)
SELECT 
    toss_decision, 
    COUNT(*) AS decision_count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM matches)), 2) AS percentage
FROM matches 
WHERE toss_decision IS NOT NULL AND toss_decision != ''
GROUP BY toss_decision;

-- Q2 Toss winner vs Match winner correlation
SELECT 
    COUNT(*) AS toss_and_match_wins,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM matches WHERE winner IS NOT NULL AND winner != '')), 2) AS win_percentage
FROM matches 
WHERE toss_winner = winner;

-- Q3 Top matches held per venue
SELECT 
    venue, 
    COUNT(*) AS total_matches 
FROM matches 
WHERE venue IS NOT NULL AND venue != ''
GROUP BY venue 
ORDER BY total_matches DESC 
LIMIT 10;

-- Q4 Highest successful run chases by venue
SELECT 
    m.venue,
    MAX(second_inn.score) AS highest_successful_chase
FROM matches m
JOIN (
    SELECT match_id, SUM(total_runs) AS score 
    FROM deliveries 
    WHERE inning = 2 
    GROUP BY match_id
) AS second_inn ON m.id = second_inn.match_id
WHERE m.result = 'runs' -- or target successfully chased
GROUP BY m.venue
ORDER BY highest_successful_chase DESC
LIMIT 10;


-- =========================================================
-- SECTION 6: ADVANCED ANALYSIS
-- =========================================================

-- Q1 Most impactful players (Player of the Match awards in winning causes)
SELECT 
    player_of_match, 
    COUNT(*) AS total_pom_awards 
FROM matches 
WHERE player_of_match IS NOT NULL AND player_of_match != ''
GROUP BY player_of_match 
ORDER BY total_pom_awards DESC 
LIMIT 10;

-- Q2 Highest partnership / Single inning team totals
SELECT 
    m.season,
    d.match_id,
    d.batting_team,
    SUM(d.total_runs) AS total_team_score
FROM deliveries d
JOIN matches m ON d.match_id = m.id
GROUP BY m.season, d.match_id, d.batting_team
ORDER BY total_team_score DESC
LIMIT 10;

-- Q3 Highest individual strike rates in high-pressure overs (Death overs 16-20, Min 100 runs)
SELECT 
    batter,
    SUM(batsman_runs) AS death_runs,
    COUNT(ball) AS death_balls,
    ROUND(SUM(batsman_runs) * 100.0 / COUNT(ball), 2) AS death_strike_rate
FROM deliveries
WHERE over_no >= 16
GROUP BY batter
HAVING death_runs >= 100
ORDER BY death_strike_rate DESC
LIMIT 10;

-- Q4 Bowlers with highest extra runs (Wides + No balls disciplined analysis)
SELECT 
    bowler, 
    SUM(extra_runs) AS total_extras_conceded,
    SUM(wide_runs) AS total_wides,
    SUM(noball_runs) AS total_noballs
FROM deliveries 
GROUP BY bowler 
ORDER BY total_extras_conceded DESC 
LIMIT 10;

-- Q5 Venue-specific average first innings score vs second innings score
SELECT 
    m.venue,
    ROUND(AVG(CASE WHEN d.inning = 1 THEN inn_score.total_runs END), 2) AS avg_1st_inn_score,
    ROUND(AVG(CASE WHEN d.inning = 2 THEN inn_score.total_runs END), 2) AS avg_2nd_inn_score
FROM matches m
JOIN (
    SELECT match_id, inning, SUM(total_runs) AS total_runs
    FROM deliveries
    GROUP BY match_id, inning
) AS inn_score ON m.id = inn_score.match_id
JOIN deliveries d ON m.id = d.match_id
WHERE m.venue IS NOT NULL AND m.venue != ''
GROUP BY m.venue
HAVING COUNT(DISTINCT m.id) >= 10
ORDER BY avg_1st_inn_score DESC
LIMIT 10;