FROM pythonbase:latest

# Set the working directory
WORKDIR /app

# Copy the dbt project into the container
COPY mlb_dbt /app/mlb_dbt

# Install dbt with PostgreSQL adapter
RUN uv pip install --upgrade \
    dbt-core \
    dbt-postgres

# Install dbt packages
RUN cd /app/mlb_dbt && dbt deps

# Ensure the dbt project profiles.yml is correctly set up
ENV DBT_PROFILES_DIR=/app/mlb_dbt

# Default command for interacting with the dbt project
CMD ["tail", "-f", "/dev/null"]