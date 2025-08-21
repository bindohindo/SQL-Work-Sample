# 1) which tournaments has each player won and how many times? -----------------------------------
    # player_id | player_name         | tournament_name     | wins
    # 105173    | Adrian Mannarino    | Astana              | 1
    # 105173    | Adrian Mannarino    | Newport             | 1
    # 105173    | Adrian Mannarino    | Sofia               | 1
    # 105173    | Adrian Mannarino    | Winston-Salem       | 1
    # 105077    | Albert Ramos        | Cordoba             | 1
    # 105077    | Albert Ramos        | Estoril             | 1
    # 126214    | Alejandro Tabilo    | Auckland            | 1
    # 126214    | Alejandro Tabilo    | Mallorca            | 1
    # 200282    | Alex De Minaur      | Acapulco            | 2
    # 200282    | Alex De Minaur      | Antalya             | 1

    SELECT
        player_stats.player_id AS player_id,
        player_stats.player_name AS player_name,
        tournament_stats.tourney_name AS tournament_name,
        COUNT(tournament_stats.winner_id) AS wins
    FROM player_stats
        LEFT JOIN tournament_stats
            ON player_stats.player_id = tournament_stats.winner_id
    WHERE player_stats.player_id IS NOT NULL && tourney_name IS NOT NULL
    GROUP BY player_id, player_name, tournament_name
    ORDER BY player_name, tournament_name
    LIMIT 10;

# 2a) which player(s) reached n tournament wins? -------------------------------------------------
    # player_name        | wins | date
    # Andrey Rublev      | 5    | 20201026
    # Novak Djokovic     | 5    | 20210524
    # Daniil Medvedev    | 5    | 20210621

    SELECT
        winner_name AS player_name,
        total_wins AS wins,
        MIN(tourney_date) AS date
    FROM
        (SELECT
             winner_id, winner_name, tourney_date,
             ROW_NUMBER() OVER(PARTITION BY winner_id ORDER BY tourney_date) AS total_wins
        FROM tournament_stats) AS sub
    WHERE total_wins = 5 # define n here
    GROUP BY player_name
    ORDER BY date
    LIMIT 3;

# 2b) which player(s) reached the highest number of tournament wins? -----------------------------
    # player_name        | wins | date
    # Daniil Medvedev    | 14   | 20231023
    # Novak Djokovic     | 14   | 20231113
    # Andrey Rublev      | 14   | 20240422

    SELECT MAX(total_wins) INTO @max
    FROM total_tournament_wins;

    SELECT
        winner_name AS player_name,
        @max AS wins,
        MIN(tourney_date) AS date
    FROM
        (SELECT
             winner_id, winner_name, tourney_date,
             ROW_NUMBER() OVER(PARTITION BY winner_id ORDER BY tourney_date) AS total_wins
        FROM tournament_stats) AS sub
    WHERE total_wins = @max
    GROUP BY player_name
    ORDER BY date;

# 3) would you recommend players be taller to win more? ------------------------------------------
    # no, there is no meaningful (linear) relationship between player height and total wins;
    # the pearson correlation coefficient ≈ 0.15

    # exploration
    SELECT
        ROUND(player_height / 10) * 10 AS height_bucket,
        ROUND(AVG(wins), 2) AS avg_wins,
        COUNT(*) AS num_players
    FROM player_stats
    WHERE player_height IS NOT NULL && player_height > 100 # filter anomalies
    GROUP BY height_bucket
    ORDER BY height_bucket;

    # height_bucket | avg_wins | num_players
    # 160           | 1.00     | 1
    # 170           | 19.71    | 17
    # 180           | 15.54    | 365
    # 190           | 20.38    | 236
    # 200           | 43.46    | 50
    # 210           | 43.00    | 3

    # at first glance, it looks like taller players have higher average wins;
    # however, small sample size is likely skewing the average for these taller height_buckets.

    # pearson correlation between player_height and wins
    WITH stats AS (
        SELECT
            player_height,
            wins,
            AVG(player_height) OVER() AS avg_height,
            AVG(wins) OVER() AS avg_wins
        FROM player_stats
        WHERE player_height IS NOT NULL && player_height > 100
    )
    SELECT
        SUM((player_height - avg_height) * (wins - avg_wins)) / # covariance
        (SQRT(SUM(POWER(player_height - avg_height, 2))) * # stddev, player_height
         SQRT(SUM(POWER(wins - avg_wins, 2)))) # stddev, wins
            AS correlation
    FROM stats;

    # coefficient ≈ 0.15

    # stats
    SELECT
        COUNT(*) AS num_players,
        ROUND(AVG(player_height), 2) AS avg_height,
        ROUND(STDDEV(player_height), 2) AS stddev_height,
        ROUND(VARIANCE(player_height), 2) AS variance_height,
        MIN(player_height) AS min_height,
        MAX(player_height) AS max_height
    FROM player_stats
    WHERE player_height IS NOT NULL && player_height > 100;

    # most players are ~186cm ±6.49cm
    # heights range from ~160cm to ~210cm, tho extremes are rare