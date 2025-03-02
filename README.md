# MLB Analytics Project

A comprehensive MLB analytics platform for fantasy baseball analysis using dbt.

## Current Features

- Daily player batting statistics
- Daily pitcher performance metrics
- Incremental model updates
- Basic statistical calculations

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
models/analytics/
├── fact_hitting_performance.sql    # Hitting statistics
├── fact_pitching_performance.sql   # Starting pitcher statistics
├── fact_relief_pitching.sql       # Relief pitcher statistics
├── fantasy_player_projections.sql  # Combined player projections
└── draft_recommendations.sql       # Final draft valuations and recommendations
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

## Project Structure

```
mlb-analytics/
├── dbtbase/
│   └── mlb_dbt/
│       ├── models/
│       │   ├── staging/      # Raw data models
│       │   ├── intermediate/ # Transformed data
│       │   └── marts/        # Final analytics models
│       ├── tests/           # Data tests
│       └── docs/            # Documentation
```

## Getting Started

1. Clone the repository
2. Install dependencies
3. Configure dbt profile
4. Run initial models: `dbt run`

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
