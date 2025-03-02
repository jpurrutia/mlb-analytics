{{ config(
    materialized='incremental',
    unique_key=['batter_id', 'game_date'],
    incremental_strategy='merge'
) }}

with daily_batting_stats as (
    select 
        p.matchup__batter__id as batter_id,
        p.matchup__batter__full_name as player_name,
        p.official_date as game_date,
        count(distinct p.about__at_bat_index) as plate_appearances,
        sum(case 
            when p.result__event_type = 'single' or p.result__event = 'Single' then 1 
            else 0 
        end) as singles,
        sum(case 
            when p.result__event_type = 'double' or p.result__event = 'Double' then 1 
            else 0 
        end) as doubles,
        sum(case 
            when p.result__event_type = 'triple' or p.result__event = 'Triple' then 1 
            else 0 
        end) as triples,
        sum(case 
            when p.result__event_type = 'home_run' or p.result__event = 'Home Run' then 1 
            else 0 
        end) as home_runs,
        sum(case 
            when p.result__event_type = 'walk' or p.result__event = 'Walk' then 1 
            else 0 
        end) as walks,
        sum(case 
            when p.result__event_type = 'strikeout' or p.result__event = 'Strikeout' then 1 
            else 0 
        end) as strikeouts,
        sum(case 
            when p.result__event_type in ('single', 'double', 'triple', 'home_run') 
                or p.result__event in ('Single', 'Double', 'Triple', 'Home Run') then 1 
            else 0 
        end) as total_hits,
        current_timestamp as _etl_loaded_at
    from {{ ref('stg_mlb_pbp') }} p
    where p.matchup__batter__id is not null
        and p.result__type = 'atBat'  -- Only count completed at-bats
    {% if is_incremental() %}
        and p.official_date >= (select max(game_date) from {{ this }})
    {% endif %}
    group by 1, 2, 3
    having count(distinct p.about__at_bat_index) > 0  -- Only include batters who had plate appearances
)

select 
    batter_id,
    player_name,
    game_date,
    plate_appearances,
    singles,
    doubles,
    triples,
    home_runs,
    walks,
    strikeouts,
    total_hits,
    case 
        when plate_appearances > 0 then round(cast(total_hits as numeric) / cast(plate_appearances as numeric), 3)
        else 0.000 
    end as batting_avg,
    case 
        when plate_appearances > 0 then round(cast((total_hits + walks) as numeric) / cast(plate_appearances as numeric), 3)
        else 0.000 
    end as on_base_pct,
    _etl_loaded_at
from daily_batting_stats
