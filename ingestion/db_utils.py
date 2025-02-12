import os

import psycopg2


def connect_to_db():
    try:
        # Use environment variables for configuration
        connection = psycopg2.connect(
            dbname=os.getenv("DB_NAME", "postgres"),
            user=os.getenv("DB_USER", "postgres"),
            password=os.getenv("DB_PASSWORD", "postgres"),
            host=os.getenv("DB_HOST", "localhost"),  # Use "db" as the hostname
            port=os.getenv("DB_PORT", 5432),
        )
        return connection
    except Exception as e:
        print(f"The error '{e}' occurred.")
        return None
