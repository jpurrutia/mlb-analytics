from datetime import datetime
from typing import Dict, Any, List
import os

import requests

import dlt


def get_mlb_players(season: str) -> List[Dict[str, Any]]:
    """Fetch all players for a given season from the MLB Stats API."""
    url = f"https://statsapi.mlb.com/api/v1/sports/1/players?season={season}"
    response = requests.get(url)
    response.raise_for_status()
    return response.json().get("people", [])


@dlt.resource(
    name="mlb_players", primary_key="id", write_disposition="merge"
)
def mlb_players_resource(seasons: List[str]):
    """
    A DLT resource that yields player data for each season.
    """
    for season in seasons:
        try:
            players = get_mlb_players(season)
            for player in players:
                player["fetched_date"] = datetime.now().isoformat()
                yield player
        except Exception as e:
            print(f"Error fetching data for season {season}: {e}")


@dlt.source
def mlb_players_source(seasons: List[str] = None):
    """
    A DLT source that returns the players resource.
    """
    if seasons is None:
        seasons = ["2023", "2024", "2025"]
    return mlb_players_resource(seasons)


if __name__ == "__main__":
    pipeline = dlt.pipeline(
        pipeline_name="mlb_players_pipeline",
        destination=dlt.destinations.postgres,
        dataset_name="mlb_data"
    )

    seasons = ["2023", "2024", "2025"]
    load_info = pipeline.run(mlb_players_source(seasons=seasons))
    print(load_info)
