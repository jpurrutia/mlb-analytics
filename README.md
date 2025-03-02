# MLB Analytics Project

A comprehensive MLB analytics platform for fantasy baseball analysis using modern data engineering tools.

## Architecture

This project implements a single-node analytics stack with:
- DLT for data extraction and loading from MLB API
- dbt (with DuckDB adapter) for transformations
- Evidence for dashboards and data exploration

## Current Features

- Daily player batting statistics
- Daily pitcher performance metrics
- Incremental model updates
- Basic statistical calculations

## Prerequisites

- Docker and Docker Compose
- Python 3.12+
- Make (for running commands)

## Quick Start

1. Clone the repository:
```bash
git clone <repository-url>
cd mlb-analytics
```

2. Copy the example environment file:
```bash
cp .env.example .env
```

3. Build and start all containers:
```bash
make setup
```

4. Run the data pipeline:
```bash
make ingest-mlb    # Run MLB data ingestion
make dbt-run       # Run dbt transformations
```

5. Access development shells:
```bash
make exec-pythonbase  # Python container shell
make exec-postgres    # PostgreSQL shell
make exec-linuxbase   # Linux container shell
```

6. Other useful commands:
```bash
make help          # Show all available commands
make status        # Check running containers
make logs c=<container>  # View container logs
make dbt-docs      # Generate dbt documentation
make dbt-test      # Run dbt tests
```

## Development Notes

Jupyter Notebooks Password: mlbanalytics

## Data Models

### Source Tables
- players
- schedule
- auction draft picks
- pbp (play by play)
- season
- mlb_teams 
- fantasy_teams
- fantasy_team_budgets

### Draft Analytics
- Projected Auction Prices (multi model regression)
- Draft Recommendations Model:
  - Player valuation based on performance metrics
  - Position-specific multipliers
  - Prospect discounting
  - Durability and performance premiums
  - Recommendation tiers (Strong Buy to Strong Sell)

### Key Models
```
models/marts/
├── core/
│   ├── daily_player_stats.sql     # Daily batting statistics
│   ├── daily_pitching_stats.sql   # Daily pitching statistics
│   └── daily_team_stats.sql       # Daily team statistics
├── analytics/
│   ├── fact_hitting_performance.sql    # Advanced hitting metrics
│   ├── fact_pitching_performance.sql   # Advanced pitching metrics
│   ├── fact_relief_pitching.sql       # Relief pitcher metrics
│   └── fantasy_player_projections.sql  # Player projections
└── ml/
    ├── player_clusters.sql        # Player clustering features
    ├── survival_metrics.sql       # Survival analysis data
    └── draft_recommendations.sql  # Draft valuations
```

### ML Tables
- Player clustering
- Survival analysis
- Player projections

## Analytics Strategy

### Advanced Metrics Implementation Plan

#### 1. Batting Advanced Metrics
- Power Metrics (SLG, ISO, OPS, OPS+)
- Plate Discipline (BB%, K%, BB/K Ratio)
- Quality of Contact Metrics
- Situational Analysis

#### 2. Pitching Advanced Metrics
- Control & Command Metrics
- Run Prevention Stats (FIP, xFIP, ERA+)
- Batted Ball Profile Analysis
- Situational Performance Metrics

#### 3. Fantasy-Specific Metrics
- Value Metrics (FPAR, Position-Adjusted Value)
- Predictive Statistics
- Composite Scoring Systems

### Required Data Sources

#### Currently Available
- Basic event outcomes (singles, doubles, triples, HR)
- At-bat results
- Pitcher/batter matchup information
- Inning and game context
- Base state information

#### Additional Data Needed

1. Pitch-Level Data
```
- pitch_data:
  * pitch_type
  * pitch_speed
  * pitch_location
  * strike_zone_status
  * swing_status
  * contact_type
```

2. Batted Ball Data
```
- batted_ball_data:
  * exit_velocity
  * launch_angle
  * hit_direction
  * hit_distance
  * contact_strength
```

3. Advanced Pitching Data
```
- detailed_pitch_data:
  * pitch_movement
  * spin_rate
  * release_point
  * release_extension
  * effective_velocity
```

4. Contextual Data
```
- game_context:
  * leverage_index
  * win_probability
  * weather_conditions
  * stadium_factors
```

### Implementation Tasks

1. Data Integration Phase
- [ ] Set up Statcast API integration
- [ ] Implement weather data pipeline
- [ ] Create league averages tables
- [ ] Build fantasy scoring configuration

2. Model Development
- [ ] Develop pitch-level analysis models
- [ ] Create batted ball profile models
- [ ] Implement advanced metric calculations
- [ ] Build fantasy scoring models

3. Quality Assurance
- [ ] Validate metric calculations
- [ ] Benchmark against known sources
- [ ] Implement data quality tests
- [ ] Create metric documentation

4. Performance Optimization
- [ ] Optimize model materialization
- [ ] Implement efficient incremental updates
- [ ] Add appropriate indexes
- [ ] Monitor and tune query performance

### Data Sources

1. Primary Sources
- MLB Statcast API
- Baseball Reference/FanGraphs
- Weather APIs
- Fantasy Platform APIs

2. Reference Data
- League-wide statistics
- Park factors
- Historical averages
- Position eligibility rules

## Environment Setup

Create a `.env` file with the following variables:
```
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=pgduckdb
DB_PORT=5432
```

## Project Structure
```
├── dbtbase/              # dbt transformation logic
├── ingestbase/           # Data ingestion pipelines
├── data/                 # Data storage
├── docker-compose.yml    # Container orchestration
└── Makefile             # Command automation
```

## Data Pipeline

### Ingestion (DLT)
- MLB Schedule Pipeline (`mlb_schedule_pipeline.py`)
- MLB Players Pipeline (`mlb_players_pipeline.py`)
- MLB Play-by-Play Pipeline (`mlb_pbp_pipeline.py`)

### Transformations (dbt)
Located in `dbtbase/mlb_dbt/models/`:
- Core models: Basic transformations
- Analytics models: Advanced metrics
- ML models: Features for machine learning

## Development

1. Build containers:
```bash
make build
```

2. Access services:
- DuckDB: localhost:5432
- Jupyter: localhost:8888 (password: mlbanalytics)

3. Run tests:
```bash
make test
```

## Troubleshooting

Common issues and solutions:

1. Database Connection:
   - Ensure PostgreSQL container is running
   - Check credentials in .env file
   - Verify port 5432 is available

2. MLB API Rate Limiting:
   - Pipeline includes automatic retry logic
   - Documented in error logs
   - Consider implementing delays between requests

3. Data Validation:
   - Check logs in `logs/` directory
   - Verify data in DuckDB using provided queries
   - Run dbt tests: `make dbt-test`

## Known Issues

Currently tracking:
- game_id: 663284 ingestion error (investigating)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
