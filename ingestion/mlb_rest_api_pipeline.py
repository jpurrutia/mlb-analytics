from typing import Any, Optional

import dlt

# from dlt.common.pendulum import pendulum
from dlt.sources.helpers import requests

# def historical_backfill(mlbam_game_ids):


if __name__ == "__main__":
    url = f"https://statsapi.mlb.com/api/v1.1/game/775294/feed/live?sportId=1"

    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Failed to retrieve data: {e}")
        exit(1)

    live_data = response.json().get("liveData", {})
    plays = live_data.get("plays", {})
    all_plays = plays.get("allPlays", {})

    pipeline = dlt.pipeline(
        pipeline_name="mlb_rest_api_pipeline",
        destination="postgres",
        dataset_name="mlb_results",
    )

    load_info = pipeline.run(
        all_plays,
        table_name="mlb_pbp",
        write_disposition="replace",
    )

    print(load_info)
