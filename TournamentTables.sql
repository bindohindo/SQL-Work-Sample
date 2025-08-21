DROP TABLE IF EXISTS all_tournaments_raw;

CREATE TABLE all_tournaments_raw AS (
    SELECT
        tourney_id,
        tourney_name,
        draw_size,
        tourney_level,
        tourney_date,
        match_num, # match_num = 300 denotes the winner of the tournament
        winner_id,
        winner_name,
        loser_id,
        loser_name
    FROM all_matches_raw
    ORDER BY tourney_name ASC, tourney_id ASC,match_num DESC
);

DROP TABLE IF EXISTS tournament_stats;

CREATE TABLE tournament_stats AS (
    SELECT
        tourney_id,
        tourney_name,
        tourney_date,
        draw_size,
        tourney_level,
        winner_id,
        winner_name,
        loser_id,
        loser_name
    FROM all_tournaments_raw
    WHERE match_num = 300
    ORDER BY tourney_name
);

DROP TABLE IF EXISTS total_tournament_wins;

CREATE TABLE total_tournament_wins AS (
    SELECT
        winner_name AS player_name,
        COUNT(winner_id) AS total_wins
    FROM tournament_stats
    GROUP BY player_name
    ORDER BY total_wins DESC
);