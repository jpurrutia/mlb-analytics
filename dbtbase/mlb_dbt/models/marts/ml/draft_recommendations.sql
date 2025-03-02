{{
    config(
        materialized='table'
    )
}}

WITH value_metrics AS (
    SELECT 
        fp.*,
        -- Calculate total value score (0-100 scale)
        CASE
            WHEN fp.position = 'Two-Way Player' THEN
                (fp.batting_value * 0.5 + fp.pitching_value * 0.5) 
            ELSE
                GREATEST(fp.batting_value, fp.pitching_value)
        END AS total_score
    FROM {{ ref('fantasy_player_projections') }} fp
),
player_age AS (
    SELECT 
        player_id,
        current_age
    FROM {{ ref('stg_mlb_players') }}
),
normalized_values AS (
    SELECT 
        vm.*,
        pa.current_age,
        -- Get primary and secondary values
        GREATEST(vm.batting_value, vm.pitching_value) AS primary_value,
        LEAST(vm.batting_value, vm.pitching_value) AS secondary_value,
        CASE
            WHEN vm.games_played < 130 
            AND vm.games_played_p < 30 
            AND pa.current_age <= 25 THEN 1
            ELSE 0
        END AS is_prospect
    FROM value_metrics vm
    LEFT JOIN player_age pa ON vm.player_id = pa.player_id
),
base_price_calc AS (
    SELECT 
        nv.*,
        CASE
            WHEN nv.position = 'Two-Way Player' THEN 
                CASE 
                    WHEN nv.total_score >= 90 THEN 50  -- Ohtani level
                    WHEN nv.total_score >= 80 THEN 40
                    WHEN nv.total_score >= 70 THEN 30
                    ELSE 20
                END
            WHEN nv.position_type = 'Pitcher' THEN
                CASE
                    WHEN nv.total_score >= 90 THEN 40  -- Elite SP like Cole
                    WHEN nv.total_score >= 80 THEN 32  -- Strong SP like Wheeler
                    WHEN nv.total_score >= 70 THEN 24
                    WHEN nv.total_score >= 60 THEN 16
                    WHEN nv.position = 'Relief Pitcher' THEN
                        CASE 
                            WHEN nv.saves_plus_holds >= 30 THEN 18
                            WHEN nv.saves_plus_holds >= 20 THEN 14
                            WHEN nv.saves_plus_holds >= 10 THEN 10
                            ELSE 6
                        END
                    ELSE 8
                END
            ELSE  -- Position players
                CASE
                    WHEN nv.total_score >= 90 THEN 46  -- Elite like Freeman
                    WHEN nv.total_score >= 80 THEN 35  -- All-Star level
                    WHEN nv.total_score >= 70 THEN 25  -- Strong starter
                    WHEN nv.total_score >= 60 THEN 15
                    ELSE 8
                END
        END AS base_price,
        CASE
            WHEN nv.position = 'Two-Way Player' THEN 1.2
            WHEN nv.position = 'Shortstop' THEN 1.15
            WHEN nv.position IN ('Second Base', 'Center Field') THEN 1.1
            WHEN nv.position = 'Catcher' AND nv.batting_average >= .260 THEN 1.1
            ELSE 1.0
        END AS position_multiplier,
        CASE
            WHEN nv.is_prospect = 1 THEN 0.8  -- Prospect discount
            ELSE 1.0
        END AS prospect_multiplier
    FROM normalized_values nv
),
premium_calc AS (
    SELECT 
        bpc.*,
        CASE
            WHEN bpc.games_played >= 150 THEN 4
            WHEN bpc.games_played >= 140 THEN 2
            ELSE 0
        END AS durability_premium,
        CASE
            WHEN bpc.position_type = 'Pitcher' THEN
                CASE
                    WHEN bpc.era < 3.00 AND bpc.strikeouts_p >= 200 THEN 8
                    WHEN bpc.era < 3.50 AND bpc.strikeouts_p >= 180 THEN 6
                    WHEN bpc.era < 4.00 AND bpc.strikeouts_p >= 160 THEN 4
                    ELSE 0
                END
            ELSE
                CASE
                    WHEN bpc.batting_average >= .300 THEN 8
                    WHEN bpc.batting_average >= .280 THEN 6
                    WHEN bpc.batting_average >= .260 THEN 4
                    ELSE 0
                END
        END AS performance_premium
    FROM base_price_calc bpc
),
final_calc AS (
    SELECT 
        ppc.*,
        ROUND(ppc.base_price * ppc.position_multiplier * ppc.prospect_multiplier + ppc.durability_premium + ppc.performance_premium, 0) AS final_price,
        CASE
            WHEN (ppc.batting_value + ppc.pitching_value) >= 85 THEN 'Strong Buy'
            WHEN (ppc.batting_value + ppc.pitching_value) >= 70 THEN 'Buy'
            WHEN (ppc.batting_value + ppc.pitching_value) >= 55 THEN 'Fair Value'
            WHEN (ppc.batting_value + ppc.pitching_value) >= 45 THEN 'Hold'
            WHEN (ppc.batting_value + ppc.pitching_value) >= 35 THEN 'Sell'
            ELSE 'Strong Sell'
        END AS recommendation
    FROM premium_calc ppc
)
SELECT 
    fc.player_id,
    fc.player_name,
    fc.position,
    fc.position_type,
    fc.games_played,
    fc.runs,
    fc.home_runs,
    fc.rbi,
    fc.stolen_bases,
    ROUND(fc.batting_average::numeric, 3) AS batting_average,
    ROUND(fc.ops::numeric, 3) AS ops,
    fc.games_played_p,
    fc.strikeouts_p,
    ROUND(fc.era::numeric, 2) AS era,
    ROUND(fc.whip::numeric, 2) AS whip,
    fc.k_bb_ratio,
    fc.quality_starts,
    fc.saves_plus_holds,
    fc.batting_value,
    fc.pitching_value,
    fc.base_price,
    fc.position_multiplier,
    fc.prospect_multiplier,
    fc.durability_premium,
    fc.performance_premium,
    fc.final_price,
    fc.recommendation
FROM final_calc fc
ORDER BY fc.final_price DESC
