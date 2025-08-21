DROP TABLE IF EXISTS player_stats;

CREATE TABLE player_stats AS
    WITH player_info AS (
        SELECT
            winner_id AS id,
            winner_name AS name,
            winner_ioc AS country,
            winner_ht AS height,
            winner_hand AS dominantHand
        FROM all_matches_raw
        UNION
        SELECT
            loser_id AS id,
            loser_name AS name,
            loser_ioc AS country,
            loser_ht AS height,
            loser_hand AS dominantHand
        FROM all_matches_raw
    ),
    match_info AS (
        SELECT
            winner_id AS player_id,
            minutes AS length,
            w_ace AS aces,
            w_df AS double_faults,
            w_1stWon AS pts_first_serve,
            w_2ndWon AS pts_second_serve,
            1 AS win,
            0 AS loss
        FROM all_matches_raw
        UNION ALL
        SELECT
            loser_id AS player_id,
            minutes AS length,
            l_ace AS aces,
            l_df AS double_faults,
            l_1stWon AS pts_first_serve,
            l_2ndWon AS pts_second_serve,
            0 AS win,
            1 AS loss
        FROM all_matches_raw
    ),
    player_stats AS (
        SELECT
            # player profile
            player_info.id AS player_id,
            player_info.name AS player_name,
            player_info.country AS player_country,
            player_info.height AS player_height,
            player_info.dominantHand AS player_dominant_hand,

            # matches
            SUM(match_info.win) AS wins,
            SUM(match_info.loss) AS losses,
            # leave nulls in instances where the player had 'invalid' matches, i.e. won/loss by opponent/player default
            ROUND(AVG(match_info.length), 2) AS avg_match,
            MIN(match_info.length) AS shortest_match,
            MAX(match_info.length) AS longest_match,

            # points
            # leave nulls in instances where the player had 'invalid' matches, i.e. won/loss by opponent/player default
            SUM(aces) AS aces,
            SUM(double_faults) AS double_faults,
            SUM(pts_first_serve) AS pts_first_serve,
            SUM(pts_second_serve) AS pts_second_serve
        FROM player_info
        LEFT JOIN match_info ON player_info.id = match_info.player_id
        GROUP BY
            player_info.id,
            player_info.name,
            player_info.country,
            player_info.height,
            player_info.dominantHand
    )
SELECT
    player_id,
    player_name,
    player_country,
    player_height,
    player_dominant_hand,
    wins + losses AS total_matches,
    wins,
    losses,
    ROUND(wins * 1.0 / (wins + losses), 2) AS win_rate,
    avg_match,
    shortest_match,
    longest_match,
    aces,
    double_faults,
    pts_first_serve,
    pts_second_serve
FROM player_stats
ORDER BY player_name;