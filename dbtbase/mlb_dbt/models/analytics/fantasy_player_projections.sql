{{
    config(
        materialized='table'
    )
}}

WITH player_positions AS (
    SELECT 
        player_id,
        full_name as player_name,
        primary_position__name as position,
        CASE 
            WHEN primary_position__name = 'Two-Way Player' THEN 'Two-Way Player'
            WHEN primary_position__type = 'Pitcher' THEN 'Pitcher'
            WHEN primary_position__name IN ('First Base', 'Second Base', 'Third Base', 'Shortstop') THEN 'Infielder'
            WHEN primary_position__name IN ('Left Field', 'Center Field', 'Right Field') THEN 'Outfielder'
            WHEN primary_position__name = 'Catcher' THEN 'Catcher'
            WHEN primary_position__name = 'Designated Hitter' THEN 'Hitter'
            ELSE primary_position__type
        END as position_type,
        active
    FROM {{ ref('stg_mlb_players') }}
    WHERE active = TRUE
),
batting_stats AS (
    SELECT 
        player_id,
        player_name,
        season,
        games_played,
        runs,
        home_runs,
        rbi,
        stolen_bases,
        batting_average,
        ops,
        NULL::integer as games_played_p,
        NULL::integer as strikeouts_p,
        NULL::decimal as era,
        NULL::decimal as whip,
        NULL::decimal as k_bb_ratio,
        NULL::integer as quality_starts,
        NULL::integer as saves_plus_holds
    FROM {{ ref('fact_hitting_performance') }}
),
pitching_stats AS (
    SELECT 
        fp.player_id,
        fp.player_name,
        fp.season,
        NULL::integer as games_played,
        NULL::integer as runs,
        NULL::integer as home_runs,
        NULL::integer as rbi,
        NULL::integer as stolen_bases,
        NULL::decimal as batting_average,
        NULL::decimal as ops,
        fp.games_pitched as games_played_p,
        fp.strikeouts as strikeouts_p,
        fp.era,
        fp.whip,
        fp.k_bb_ratio,
        fp.quality_starts,
        COALESCE(rp.saves + rp.holds, 0) as saves_plus_holds
    FROM {{ ref('fact_pitching_performance') }} fp
    LEFT JOIN {{ ref('fact_relief_pitching') }} rp 
        ON fp.player_id = rp.player_id 
        AND fp.season = rp.season
),
combined_stats AS (
    -- Get both pitching and hitting stats for two-way players
    SELECT 
        COALESCE(b.player_id, p.player_id) as player_id,
        COALESCE(b.player_name, p.player_name) as player_name,
        COALESCE(b.season, p.season) as season,
        b.games_played,
        b.runs,
        b.home_runs,
        b.rbi,
        b.stolen_bases,
        b.batting_average,
        b.ops,
        p.games_played_p,
        p.strikeouts_p,
        p.era,
        p.whip,
        p.k_bb_ratio,
        p.quality_starts,
        p.saves_plus_holds
    FROM batting_stats b
    FULL OUTER JOIN pitching_stats p 
        ON b.player_id = p.player_id 
        AND b.season = p.season
),
value_metrics AS (
    SELECT 
        cs.*,
        pp.position,
        pp.position_type,
        -- Batting value score (0-100)
        CASE 
            WHEN batting_average IS NOT NULL THEN
                -- Batting Average (0-20)
                (CASE WHEN batting_average >= .320 THEN 20
                      WHEN batting_average >= .300 THEN 16
                      WHEN batting_average >= .280 THEN 12
                      WHEN batting_average >= .260 THEN 8
                      WHEN batting_average >= .240 THEN 4
                      ELSE 0 END) +
                -- OPS (0-25)
                (CASE WHEN ops >= 1.000 THEN 25
                      WHEN ops >= .900 THEN 20
                      WHEN ops >= .800 THEN 15
                      WHEN ops >= .700 THEN 8
                      WHEN ops >= .600 THEN 4
                      ELSE 0 END) +
                -- Home Runs (0-25)
                (CASE WHEN home_runs >= 40 THEN 25
                      WHEN home_runs >= 30 THEN 20
                      WHEN home_runs >= 20 THEN 15
                      WHEN home_runs >= 10 THEN 8
                      WHEN home_runs >= 5 THEN 4
                      ELSE 0 END) +
                -- RBI (0-15)
                (CASE WHEN rbi >= 100 THEN 15
                      WHEN rbi >= 80 THEN 12
                      WHEN rbi >= 60 THEN 8
                      WHEN rbi >= 40 THEN 4
                      ELSE 0 END) +
                -- Runs (0-15)
                (CASE WHEN runs >= 100 THEN 15
                      WHEN runs >= 80 THEN 12
                      WHEN runs >= 60 THEN 8
                      WHEN runs >= 40 THEN 4
                      ELSE 0 END)
            ELSE 0
        END as batting_value,
        
        -- Pitching value score (0-100)
        CASE 
            WHEN era IS NOT NULL THEN
                CASE WHEN quality_starts IS NOT NULL THEN
                    -- Starting Pitcher
                    -- ERA (0-30)
                    (CASE WHEN era < 2.50 THEN 30
                          WHEN era < 3.00 THEN 24
                          WHEN era < 3.50 THEN 18
                          WHEN era < 4.00 THEN 12
                          WHEN era < 4.50 THEN 6
                          ELSE 0 END) +
                    -- WHIP (0-30)
                    (CASE WHEN whip < 1.00 THEN 30
                          WHEN whip < 1.10 THEN 24
                          WHEN whip < 1.20 THEN 18
                          WHEN whip < 1.30 THEN 12
                          WHEN whip < 1.40 THEN 6
                          ELSE 0 END) +
                    -- Strikeouts (0-25)
                    (CASE WHEN strikeouts_p >= 220 THEN 25
                          WHEN strikeouts_p >= 180 THEN 20
                          WHEN strikeouts_p >= 140 THEN 15
                          WHEN strikeouts_p >= 100 THEN 8
                          WHEN strikeouts_p >= 60 THEN 4
                          ELSE 0 END) +
                    -- Quality Starts (0-15)
                    (CASE WHEN quality_starts >= 25 THEN 15
                          WHEN quality_starts >= 20 THEN 12
                          WHEN quality_starts >= 15 THEN 9
                          WHEN quality_starts >= 10 THEN 6
                          WHEN quality_starts >= 5 THEN 3
                          ELSE 0 END)
                ELSE
                    -- Relief Pitcher
                    -- ERA (0-35)
                    (CASE WHEN era < 2.00 THEN 35
                          WHEN era < 2.50 THEN 28
                          WHEN era < 3.00 THEN 21
                          WHEN era < 3.50 THEN 14
                          WHEN era < 4.00 THEN 7
                          ELSE 0 END) +
                    -- WHIP (0-35)
                    (CASE WHEN whip < 0.90 THEN 35
                          WHEN whip < 1.00 THEN 28
                          WHEN whip < 1.10 THEN 21
                          WHEN whip < 1.20 THEN 14
                          WHEN whip < 1.30 THEN 7
                          ELSE 0 END) +
                    -- Saves + Holds (0-30)
                    (CASE WHEN saves_plus_holds >= 40 THEN 30
                          WHEN saves_plus_holds >= 30 THEN 24
                          WHEN saves_plus_holds >= 20 THEN 18
                          WHEN saves_plus_holds >= 10 THEN 12
                          WHEN saves_plus_holds >= 5 THEN 6
                          ELSE 0 END)
                END
            ELSE 0
        END as pitching_value
    FROM combined_stats cs
    JOIN player_positions pp ON cs.player_id = pp.player_id
)

SELECT DISTINCT
    vm.player_id,
    vm.player_name,
    vm.position,
    vm.position_type,
    vm.games_played,
    vm.runs,
    vm.home_runs,
    vm.rbi,
    vm.stolen_bases,
    vm.batting_average,
    vm.ops,
    vm.games_played_p,
    vm.strikeouts_p,
    vm.era,
    vm.whip,
    vm.k_bb_ratio,
    vm.quality_starts,
    vm.saves_plus_holds,
    vm.batting_value,
    vm.pitching_value
FROM value_metrics vm
WHERE vm.season = (SELECT MAX(season) FROM combined_stats)
