# Default target
.PHONY: help
help:
	@echo "MLB Analytics Project Make Commands"
	@echo ""
	@echo "Docker Management:"
	@echo "  setup         - Build and start all containers"
	@echo "  rebuild       - Force rebuild and start containers"
	@echo "  stop         - Stop all containers"
	@echo "  clean        - Remove all containers, volumes, and images"
	@echo "  status       - Check running containers"
	@echo "  logs         - Show container logs (use c=container_name)"
	@echo ""
	@echo "Development Shells:"
	@echo "  exec-pythonbase  - Shell into Python container"
	@echo "  exec-postgres    - PostgreSQL shell"
	@echo "  exec-linuxbase   - Shell into Linux container"
	@echo ""
	@echo "Data Pipeline:"
	@echo "  ingest-mlb      - Run MLB data ingestion pipeline"
	@echo "  ingest-fantasy  - Run fantasy data ingestion"
	@echo ""
	@echo "DBT Commands:"
	@echo "  dbt-run        - Run all dbt models"
	@echo "  dbt-test       - Run dbt tests"
	@echo "  dbt-docs       - Generate dbt documentation"
	@echo "  dbt-clean      - Clean dbt artifacts"
	@echo ""
	@echo "ML Pipeline:"
	@echo "  train-models   - Train ML models"
	@echo "  evaluate       - Evaluate model performance"
	@echo ""
	@echo "Quality Checks:"
	@echo "  lint          - Run code linting"
	@echo "  test          - Run Python tests"
	@echo "  check-all     - Run all quality checks"

# Docker Management
setup:
	@docker compose build
	@docker compose up -d

rebuild:
	@docker compose build --no-cache
	@docker compose up -d

stop:
	@docker compose down

clean:
	@docker compose down -v --rmi all --remove-orphans

status:
	@docker compose ps

logs:
	@docker compose logs -f $(c)

# Development Shells
exec-pythonbase:
	@docker compose up -d pythonbase
	@docker compose exec pythonbase bash

exec-postgres:
	@docker compose up -d pgduckdb
	@docker compose exec pgduckdb psql -U postgres -d postgres

exec-linuxbase:
	@docker compose up -d linuxbase
	@docker compose exec linuxbase bash

# Data Pipeline
ingest-mlb:
	@docker compose up -d ingestbase
	# @docker compose exec ingestbase python -m ingestbase.mlb_schedule_pipeline
	#@docker compose exec ingestbase python -m ingestbase.mlb_players_pipeline
	@docker compose exec ingestbase python -m ingestbase.mlb_pbp_pipeline

#ingest-fantasy:
#	@docker compose exec pythonbase python -m ingestion.fantasy_draft_pipeline

# DBT Commands
dbt-run:
	@docker compose up -d dbtbase
	@docker compose exec dbtbase bash -c "cd mlb_dbt && dbt run"

dbt-test:
	@docker compose up -d dbtbase
	@docker compose exec dbtbase bash -c "cd mlb_dbt && dbt test"

dbt-docs:
	@docker compose up -d dbtbase
	@docker compose exec dbtbase bash -c "cd mlb_dbt && dbt docs generate && dbt docs serve"

dbt-clean:
	@docker compose up -d dbtbase
	@docker compose exec dbtbase bash -c "cd mlb_dbt && dbt clean"

# ML Pipeline
#train-models:
#	@docker compose exec mlpythonbase python -m ml.train_models

#evaluate:
#	@docker compose exec mlpythonbase python -m ml.evaluate_models

# Quality Checks
#lint:
#	@docker compose exec pythonbase ruff check .

test:
	@docker compose up -d pythonbase
	@docker compose exec pythonbase pytest tests/

check-all: test dbt-test