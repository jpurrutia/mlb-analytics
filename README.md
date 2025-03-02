# MLB Analytics Project

A comprehensive MLB analytics platform for fantasy baseball analysis using modern data engineering tools.

## Architecture

This project implements a single-node analytics stack with:
- DLT for data extraction and loading from MLB API
- dbt (with DuckDB adapter) for transformations
- Evidence for dashboards and data exploration

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

3. Start the services:
```bash
make up
```

4. Run the data pipeline:
```bash
make ingest-mlb    # Ingest MLB data
make dbt-run       # Transform data with dbt
```

## Environment Variables

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
