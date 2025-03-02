{{
    config(
        materialized='incremental',
        unique_key=['pitcher_id', 'game_date'],
        incremental_strategy='merge'
    )
}}

with daily_pitching_stats as (
    select 
        p.matchup__pitcher__id as pitcher_id,
        p.matchup__pitcher__full_name as player_name,
        p.official_date as game_date,
        count(distinct p.about__at_bat_index) as batters_faced,
        sum(case 
            when p.result__event_type = 'strikeout' or p.result__event = 'Strikeout' then 1 
            else 0 
        end) as strikeouts,
        sum(case 
            when p.result__event_type = 'walk' or p.result__event = 'Walk' then 1 
            else 0 
        end) as walks,
        sum(case 
            when p.result__event_type in ('single', 'double', 'triple', 'home_run')
                or p.result__event in ('Single', 'Double', 'Triple', 'Home Run') then 1 
            else 0 
        end) as hits_allowed,
        sum(case 
            when p.result__event_type = 'home_run' or p.result__event = 'Home Run' then 1 
            else 0 
        end) as home_runs_allowed,
        max(p.about__inning)::integer as innings_pitched,
        sum(case 
            when p.result__event_type in ('single', 'double', 'triple', 'home_run', 'walk')
                or p.result__event in ('Single', 'Double', 'Triple', 'Home Run', 'Walk') then 1 
            else 0 
        end) as baserunners_allowed,
        current_timestamp as _etl_loaded_at
    from {{ ref('stg_mlb_pbp') }} p
    where p.matchup__pitcher__id is not null
        and p.result__type = 'atBat'  -- Only count completed at-bats
    {% if is_incremental() %}
        and p.official_date >= (select max(game_date) from {{ this }})
    {% endif %}
    group by 1, 2, 3
    having count(distinct p.about__at_bat_index) > 0  -- Only include pitchers who faced batters
)

select 
    pitcher_id,
    player_name,
    game_date,
    batters_faced,
    strikeouts,
    walks,
    hits_allowed,
    home_runs_allowed,
    innings_pitched,
    baserunners_allowed,
    case 
        when batters_faced > 0 then round(cast(strikeouts as numeric) / cast(batters_faced as numeric), 3)
        else 0.000 
    end as strikeout_rate,
    case 
        when batters_faced > 0 then round(cast(walks as numeric) / cast(batters_faced as numeric), 3)
        else 0.000 
    end as walk_rate,
    case 
        when batters_faced > 0 then round(cast(hits_allowed as numeric) / cast(batters_faced as numeric), 3)
        else 0.000 
    end as hits_per_batter,
    case 
        when innings_pitched > 0 then round(cast(baserunners_allowed as numeric) / cast(innings_pitched as numeric), 3)
        else 0.000 
    end as whip,
    case 
        when innings_pitched > 0 then round((cast(strikeouts as numeric) * 9) / cast(innings_pitched as numeric), 3)
        else 0.000 
    end as k_per_9,
    _etl_loaded_at
from daily_pitching_stats
where innings_pitched > 0
