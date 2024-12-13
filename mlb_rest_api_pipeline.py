from typing import Any, Optional

import dlt

# from dlt.common.pendulum import pendulum
from dlt.sources.helpers import requests


if __name__ == "__main__":
    url = f"https://statsapi.mlb.com/api/v1.1/game/775294/feed/live?sportId=1"

    response = requests.get(url)
    live_data = response.json().get("liveData", [])

    if response.raise_for_status():
        print("Error: ", response.raise_for_status())

    pipeline = dlt.pipeline(
        pipeline_name="rest_api_pipeline",
        destination="duckdb",
        dataset_name="mlb_results",
    )

    load_info = pipeline.run(
        live_data["plays"]["allPlays"],
        table_name="mlb_games",
        write_disposition="replace",
    )

    print(load_info)
