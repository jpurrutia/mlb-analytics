{{
    config(
        materialized='table'
    )
}}

WITH game_final_outs AS (
    SELECT 
        game_pk,
        matchup__pitcher__id AS player_id,
        matchup__pitcher__full_name AS player_name,
        EXTRACT(YEAR FROM about__start_time::date) as season,
        result__event,
        about__inning,
        result__away_score,
        result__home_score,
        about__is_top_inning,
        ROW_NUMBER() OVER (PARTITION BY game_pk ORDER BY about__end_time DESC) as last_play_rank
    FROM mlb_data.mlb_pbp
    WHERE result__is_out = TRUE
),
game_situations AS (
    SELECT
        game_pk,
        player_id,
        player_name,
        season,
        -- Save situation: Leading by 3 or fewer runs in the final inning
        CASE WHEN (about__is_top_inning = FALSE AND result__home_score > result__away_score AND 
                  result__home_score - result__away_score <= 3)
             OR (about__is_top_inning = TRUE AND result__away_score > result__home_score AND
                 result__away_score - result__home_score <= 3)
        THEN 1 ELSE 0 END as is_save_situation,
        -- Hold situation: Leading by 3 or fewer runs before the 9th inning
        CASE WHEN about__inning < 9 AND
                  ((about__is_top_inning = FALSE AND result__home_score > result__away_score AND 
                    result__home_score - result__away_score <= 3)
                   OR 
                   (about__is_top_inning = TRUE AND result__away_score > result__home_score AND
                    result__away_score - result__home_score <= 3))
        THEN 1 ELSE 0 END as is_hold_situation
    FROM game_final_outs
    WHERE last_play_rank = 1
)

SELECT 
    player_id,
    player_name,
    season,
    SUM(is_save_situation) as saves,
    SUM(is_hold_situation) as holds,
    SUM(is_save_situation) + SUM(is_hold_situation) as saves_plus_holds
FROM game_situations
GROUP BY player_id, player_name, season
