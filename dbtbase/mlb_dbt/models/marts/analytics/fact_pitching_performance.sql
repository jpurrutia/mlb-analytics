{{
    config(
        materialized='table'
    )
}}

WITH pitcher_events AS (
    SELECT 
        p.matchup__pitcher__id AS player_id,
        p.matchup__pitcher__full_name AS player_name,
        EXTRACT(YEAR FROM p.about__start_time::date) as season,
        COUNT(DISTINCT p.game_pk) AS games_pitched,
        COUNT(*) AS batters_faced,
        -- Strikeouts
        SUM(CASE WHEN result__event = 'Strikeout' THEN 1 ELSE 0 END) AS strikeouts,
        -- Walks
        SUM(CASE WHEN result__event IN ('Walk', 'Intent Walk') THEN 1 ELSE 0 END) AS walks,
        -- Hits
        SUM(CASE WHEN result__event IN ('Single', 'Double', 'Triple', 'Home Run') THEN 1 ELSE 0 END) AS hits,
        -- Earned Runs (approximation since we don't have explicit earned runs)
        SUM(CASE WHEN about__is_scoring_play = TRUE THEN 1 ELSE 0 END) AS runs_allowed,
        -- Innings Pitched (approximation: 1 out = 1/3 inning)
        SUM(CASE WHEN result__is_out = TRUE THEN 1 ELSE 0 END)::decimal / 3 AS innings_pitched
    FROM mlb_data.mlb_pbp p
    WHERE p.matchup__pitcher__id IS NOT NULL
    GROUP BY player_id, player_name, season
),
quality_starts AS (
    SELECT 
        p.matchup__pitcher__id AS player_id,
        EXTRACT(YEAR FROM p.about__start_time::date) as season,
        p.game_pk,
        SUM(CASE WHEN result__is_out = TRUE THEN 1 ELSE 0 END)::decimal / 3 AS innings_in_game,
        SUM(CASE WHEN about__is_scoring_play = TRUE THEN 1 ELSE 0 END) AS runs_in_game
    FROM mlb_data.mlb_pbp p
    WHERE p.matchup__pitcher__id IS NOT NULL
    GROUP BY player_id, season, game_pk
    HAVING SUM(CASE WHEN result__is_out = TRUE THEN 1 ELSE 0 END)::decimal / 3 >= 6 
    AND SUM(CASE WHEN about__is_scoring_play = TRUE THEN 1 ELSE 0 END) <= 3
)

SELECT 
    pe.player_id,
    pe.player_name,
    pe.season,
    pe.games_pitched,
    pe.strikeouts,
    pe.walks,
    pe.hits,
    pe.innings_pitched,
    pe.runs_allowed,
    -- ERA = (earned runs / innings pitched) * 9
    ROUND(CAST(pe.runs_allowed AS DECIMAL) / NULLIF(pe.innings_pitched, 0) * 9, 2) as era,
    -- WHIP = (walks + hits) / innings pitched
    ROUND(CAST(pe.walks + pe.hits AS DECIMAL) / NULLIF(pe.innings_pitched, 0), 2) as whip,
    -- K/BB ratio
    ROUND(CAST(pe.strikeouts AS DECIMAL) / NULLIF(pe.walks, 0), 2) as k_bb_ratio,
    -- K/9 (strikeouts per 9 innings)
    ROUND(CAST(pe.strikeouts AS DECIMAL) / NULLIF(pe.innings_pitched, 0) * 9, 2) as k_9,
    -- Quality Starts
    COUNT(DISTINCT qs.game_pk) as quality_starts
FROM pitcher_events pe
LEFT JOIN quality_starts qs ON pe.player_id = qs.player_id AND pe.season = qs.season
GROUP BY 
    pe.player_id,
    pe.player_name,
    pe.season,
    pe.games_pitched,
    pe.strikeouts,
    pe.walks,
    pe.hits,
    pe.innings_pitched,
    pe.runs_allowed
