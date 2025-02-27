-- Ensure the schema exists
CREATE SCHEMA IF NOT EXISTS mlb_data;

-- Drop table if it already exists
DROP TABLE IF EXISTS mlb_data.draft_prices;

-- Create the table
CREATE TABLE mlb_data.draft_prices (
    player_id INTEGER,
    team_name VARCHAR,
    manager VARCHAR,
    player_name VARCHAR,
    draft_price INTEGER,
    is_keeper INTEGER,
    season INTEGER
);

-- Copy data from the CSV file
COPY mlb_data.draft_prices (player_id, team_name, manager, player_name, draft_price, is_keeper, season)
FROM '/data/mlb_fantasy_draft_prices_utf8.csv'  -- Use mounted path
DELIMITER ','
CSV HEADER;
