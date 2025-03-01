{{
    config(
        materialized='view'
    )
}}

select
    id as player_id,
    full_name,
    first_name,
    last_name,
    primary_number,
    birth_date,
    current_age,
    birth_city,
    birth_country,
    height,
    weight,
    active,
    current_team__id,
    current_team__name,
    primary_position__code,
    primary_position__name,
    primary_position__type,
    primary_position__abbreviation,
    bat_side__code,
    bat_side__description,
    pitch_hand__code,
    pitch_hand__description,
    mlb_debut_date,
    last_played_date
from mlb_data.mlb_players
