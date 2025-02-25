FROM pythonbase:latest

# Set the working directory
WORKDIR /app

# Copy the dbt project into the container
COPY mlb_dbt /app/mlb_dbt

# Install dbt
RUN uv pip install --update \
    dbt-core \
    dbt-postgres

# Ensure the dbt project profiles.yml is correctly set up
ENV DBT_PROFILES_DIR=/app/dbt

# Default command for interacting with the dbt project
CMD ["tail", "-f", "/dev/null"]