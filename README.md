1. Git clone this repository:
    - creates the 'mlb-analytics' folder in your local projects folders

2. Pip install uv

3. UV python install
https://docs.astral.sh/uv/guides/projects/

4. activate uv environment
```bash

```






Project Management
```bash
$ uv init mlb-analytics

$ cd mlb-analytics

$ uv add ruff

$ uv run ruff check
```

Install packages
```bash
$ uv pip install pandas
```


Questions:
- How to make updates for package versions, python versions, etc.?


Python management
```bash

$ uv python install 3.11 
```

Use specific python version in current directory
```bash
$ uv venv --python 3.11;

$ uv python pin pypy@3.11;
```

Docker Compose
This is what we use to launch our postgres and duckdb databases
```bash
docker compose up -d

docker compose exec pgduckdb psql

docker compose down
```

dlt Project Setup
```bash
$ uv pip install dlt

$ dlt --version

$ dlt init rest_api duckdb
```



Postgres User Setup for DLT loader

Enter credentials into `.dlt/secrets.toml`

```sql
CREATE USER loader;

ALTER USER 'loader' SET pg_user.passwd TO 'data_loader';
```
