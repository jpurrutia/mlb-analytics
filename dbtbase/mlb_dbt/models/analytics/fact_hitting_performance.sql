{{
    config(
        materialized='table'
    )
}}

WITH batter_events AS (
    SELECT 
        p.matchup__batter__id AS player_id,
        p.matchup__batter__full_name AS player_name,
        EXTRACT(YEAR FROM p.about__start_time::date) as season,
        COUNT(DISTINCT p.game_pk) AS games_played,
        COUNT(*) AS plate_appearances,
        SUM(CASE WHEN result__event = 'Single' THEN 1 ELSE 0 END) AS singles,
        SUM(CASE WHEN result__event = 'Double' THEN 1 ELSE 0 END) AS doubles,
        SUM(CASE WHEN result__event = 'Triple' THEN 1 ELSE 0 END) AS triples,
        SUM(CASE WHEN result__event = 'Home Run' THEN 1 ELSE 0 END) AS home_runs,
        SUM(CASE WHEN result__event IN ('Walk', 'Intent Walk') THEN 1 ELSE 0 END) AS walks,
        SUM(CASE WHEN result__event = 'Strikeout' THEN 1 ELSE 0 END) AS strikeouts,
        SUM(CASE WHEN result__event IN ('Stolen Base 2B', 'Stolen Base 3B') THEN 1 ELSE 0 END) AS stolen_bases,
        SUM(CASE WHEN result__event IN ('Caught Stealing 2B', 'Caught Stealing 3B', 'Caught Stealing Home') THEN 1 ELSE 0 END) AS caught_stealing,
        SUM(CASE WHEN result__event IN ('Single', 'Double', 'Triple', 'Home Run') THEN 1 ELSE 0 END) AS hits,
        COUNT(CASE WHEN result__event NOT IN ('Walk', 'Intent Walk', 'Hit By Pitch') THEN 1 END) AS at_bats,
        SUM(result__rbi) AS rbi,
        SUM(CASE WHEN about__is_scoring_play = TRUE THEN 1 ELSE 0 END) AS runs,
        SUM(CASE 
            WHEN result__event = 'Single' THEN 1
            WHEN result__event = 'Double' THEN 2
            WHEN result__event = 'Triple' THEN 3
            WHEN result__event = 'Home Run' THEN 4
            ELSE 0 END) AS total_bases
    FROM {{ ref('stg_mlb_pbp') }} p
    WHERE p.matchup__batter__id IS NOT NULL
    GROUP BY player_id, player_name, season
)

SELECT 
    player_id,
    player_name,
    season,
    games_played,
    plate_appearances,
    at_bats,
    runs,
    hits,
    singles,
    doubles,
    triples,
    home_runs,
    rbi,
    walks,
    strikeouts,
    stolen_bases,
    caught_stealing,
    ROUND(CAST(hits AS NUMERIC) / NULLIF(at_bats, 0), 3) as batting_average,
    ROUND(CAST(hits + walks AS NUMERIC) / NULLIF(plate_appearances, 0), 3) as on_base_percentage,
    ROUND(CAST(total_bases AS NUMERIC) / NULLIF(at_bats, 0), 3) as slugging_percentage,
    ROUND(CAST(hits + walks AS NUMERIC) / NULLIF(plate_appearances, 0), 3) + 
    ROUND(CAST(total_bases AS NUMERIC) / NULLIF(at_bats, 0), 3) as ops,
    total_bases
FROM batter_events
