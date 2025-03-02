# Data Files

## MLB Fantasy Draft Prices

Two versions of the fantasy draft prices data are maintained:

1. `mlb_fantasy_draft_prices.csv`
   - Original data file
   - Contains raw draft price data

2. `mlb_fantasy_draft_prices_utf8.csv`
   - UTF-8 encoded version
   - Cleaned and standardized for database ingestion
   - Use this version for data loading

Note: Always use the UTF-8 version when loading data into the database to ensure proper character encoding handling.
