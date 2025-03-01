{{
    config(
        materialized='view'
    )
}}

select
    player_id,
    team_name,
    manager,
    player_name,
    draft_price,
    is_keeper,
    season
from mlb_data.draft_prices
