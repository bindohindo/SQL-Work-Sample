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
        # wins
        SELECT
            winner_id AS id,
            minutes AS length,
            1 AS win,
            0 AS loss
        FROM all_matches_raw
        UNION ALL
        SELECT
            loser_id AS id,
            minutes AS length,
            0 AS win,
            1 AS loss
        FROM all_matches_raw
    ),
    playerStats AS (
        SELECT
            # player profile
            player_info.id,
            player_info.name,
            player_info.country,
            player_info.height,
            player_info.dominantHand,

            # matches
            SUM(match_info.win) AS wins,
            SUM(match_info.loss) AS losses,
            ROUND(AVG(match_info.length), 2) AS avg_match,
            MIN(match_info.length) AS shortest_match,
            MAX(match_info.length) AS longest_match

        FROM player_info
        LEFT JOIN match_info ON player_info.id = match_info.id
        GROUP BY
            player_info.id,
            player_info.name,
            player_info.country,
            player_info.height,
            player_info.dominantHand
    )
SELECT
    id,
    name,
    country,
    wins + losses AS totalMatches,
    wins,
    losses,
    ROUND(wins * 1.0 / (wins + losses), 2) AS win_rate,
    avg_match,
    shortest_match,
    longest_match
FROM playerStats
ORDER BY name;