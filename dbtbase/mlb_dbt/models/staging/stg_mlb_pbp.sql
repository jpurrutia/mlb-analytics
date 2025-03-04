{{
    config(
        materialized='view'
    )
}}

select
    result__type,
    result__event,
    result__event_type,
    result__description,
    result__rbi,
    result__away_score,
    result__home_score,
    result__is_out,
    about__at_bat_index,
    about__half_inning,
    about__is_top_inning,
    about__inning,
    about__start_time,
    about__end_time,
    about__is_complete,
    about__is_scoring_play,
    about__has_review,
    about__has_out,
    about__captivating_index,
    count__balls,
    count__strikes,
    count__outs,
    matchup__batter__id,
    matchup__batter__full_name,
    matchup__bat_side__code,
    matchup__bat_side__description,
    matchup__pitcher__id,
    matchup__pitcher__full_name,
    matchup__pitch_hand__code,
    matchup__pitch_hand__description,
    matchup__post_on_first__id,
    matchup__post_on_first__full_name,
    matchup__post_on_second__id,
    matchup__post_on_second__full_name,
    matchup__post_on_third__id,
    matchup__post_on_third__full_name,
    play_end_time,
    at_bat_index,
    game_pk,
    official_date
from mlb_data.mlb_pbp
