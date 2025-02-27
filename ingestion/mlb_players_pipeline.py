from datetime import datetime, timezone
from typing import Dict, Any, List

import requests
import dlt


def get_mlb_players(season: str) -> List[Dict[str, Any]]:
    """Fetch player data for a given MLB season from the Stats API."""
    url = f"https://statsapi.mlb.com/api/v1/sports/1/players?season={season}"
    response = requests.get(url)
    response.raise_for_status()
    data = response.json()

    return data.get("people", [])  # Ensure a list is returned


@dlt.resource(name="mlb_players", primary_key="id", write_disposition="merge")
def mlb_player_resource(season: str):
    """
    A DLT resource that yields player data for each season.
    """
    try:
        players_list = get_mlb_players(season)

        if not players_list:
            print(f"⚠️ No players found for season {season}")
            return  # Avoid yielding an empty list

        fetched_date = datetime.now(timezone.utc).isoformat()  # Ensure UTC datetime

        for player in players_list:
            if not isinstance(player, dict) or "id" not in player:
                print(f"⚠️ Skipping invalid player data: {player}")
                continue  # Skip malformed records

            # **Ensure fetched_date is always included**
            player["fetched_date"] = fetched_date

            yield player  # ✅ Yield each record correctly

        print(
            f"✅ Successfully fetched and processed {len(players_list)} players for season {season}"
        )

    except Exception as e:
        print(f"❌ Error fetching data for season {season}: {e}")


@dlt.source
def mlb_source(season: str = None):
    """
    A DLT source that returns one or more resources.
    """
    season = season or dlt.config.get("season", "2024")  # Default to 2024 if unset
    if not isinstance(season, str):
        raise ValueError(f"Invalid season value: {season}")

    return mlb_player_resource(season)


if __name__ == "__main__":

    seasons = ["2023", "2024", "2025"]

    pipeline = dlt.pipeline(
        pipeline_name="mlb_player_pipeline",
        destination="postgres",
        dataset_name="mlb_data",
    )

    for season in seasons:
        load_info = pipeline.run(mlb_source(season=season))

    print(load_info)
