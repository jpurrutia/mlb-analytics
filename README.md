# MLB Analytics Stack

A modern analytics stack for MLB data analysis using DuckDB, dbt, and Evidence.

## Architecture

This project implements a single-node analytics stack with:
- DLT for data extraction and loading from MLB API
- dbt (with DuckDB adapter) for transformations
- Evidence for dashboards and data exploration

## Project Structure

```
mlb-analytics/
├── .dlt/                  # DLT configuration
├── data/                  # Raw data storage
├── dbt/                   # dbt transformations
│   ├── models/
│   └── dbt_project.yml
├── evidence/             # Evidence dashboards
├── ingestion/            # Data ingestion scripts
└── requirements.txt      # Python dependencies
```

## Setup & Installation

1. Create and activate virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

1. **Data Extraction & Loading**:
```bash
dlt pipeline <command>
```

2. **Run Transformations**:
```bash
dbt run
```

3. **View Dashboards**:
Access Evidence dashboards at http://localhost:3000 when running locally.

## Development

- Data is stored in DuckDB (`rest_api_pipeline.duckdb`)
- Transformations are managed through dbt
- Visualizations are built using Evidence

## License

Proprietary - All rights reserved

Jupyter Notebooks:

password: 
- mlbanalytics

Data Modeling:

Conceptual:

Source Tables:
- players
- schedule
- auction draft picks
- pbp
- season
- mlb_teams 
- fantasy_teams
- fantasy_team_budgets

Aggregate Tables:
- game aggregate
- season aggregate w/ draft prices
- fantasy team analytics
- position leaderboards

Draft Analytics Table:
- Projected Auction Prices - regression (multi model regression)
- Draft Recommendations Model:
  - Player valuation based on performance metrics
  - Position-specific multipliers
  - Prospect discounting
  - Durability and performance premiums
  - Recommendation tiers (Strong Buy to Strong Sell)

Key Models:
```
models/analytics/
├── fact_hitting_performance.sql    # Hitting statistics
├── fact_pitching_performance.sql   # Starting pitcher statistics
├── fact_relief_pitching.sql       # Relief pitcher statistics
├── fantasy_player_projections.sql  # Combined player projections
└── draft_recommendations.sql       # Final draft valuations and recommendations
```

ML Tables:
- table for player clustering players
- table for survival analysis
- table for player projections
