import dlt

# from dlt.common.pendulum import pendulum
from dlt.sources.helpers import requests


if __name__ == "__main__":
    url = "https://api.pbpstats.com/get-games/nba?Season=2024-25&SeasonType=Regular%20Season"

    response = requests.get(url)

    pipeline = dlt.pipeline(
        pipeline_name="rest_api_pipeline",
        destination="duckdb",
        dataset_name="results",
    )

    load_info = pipeline.run(
        response.json().get("results", []),
        table_name="nba_games",
        write_disposition="replace",
    )

    print(load_info)
