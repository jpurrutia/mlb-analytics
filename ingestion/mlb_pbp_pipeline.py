import time
import requests
from typing import Dict, Any
from collections.abc import Iterator

import dlt
from dlt.sources.rest_api import RESTAPIConfig, rest_api_source
from psycopg2 import OperationalError, DatabaseError

from db_utils import connect_to_db


def read_game_ids() -> Iterator[str]:
    """
    Generator that reads and yields game IDs from the schedule table.
    """
    db = connect_to_db()
    cur = db.cursor()

    try:
        cur.execute(
            """
            SELECT DISTINCT game_pk
            FROM mlb_data.mlb_schedule__dates__games
            WHERE official_date BETWEEN '2022-04-01'::text AND CURRENT_DATE::text
            AND series_description = 'Regular Season';
            """
        )
        for (game_pk,) in cur.fetchall():
            yield game_pk
    except Exception as e:
        print(f"Database error occurred while reading game IDs: {e}")
    finally:
        cur.close()
        db.close()


@dlt.resource(
    # primary_key=["gamePk"],
    name="mlb_pbp",
    write_disposition="replace",
    # table_name="mlb_pbp",
)
def mlbam_pbp_resource() -> Iterator[Dict[str, Any]]:
    """Resource that fetches pbp data for each game."""
    for game_id in read_game_ids():
        try:
            response = requests.get(
                f"https://statsapi.mlb.com/api/v1.1/game/{game_id}/feed/live?sportId=1"
            )
            response.raise_for_status()

            pbp_data = response.json()

            # process the response to get all plays
            live_data = response.json().get("liveData", {})
            plays = live_data.get("plays", {})
            all_plays = plays.get("allPlays", [])

            game_pk = pbp_data.get("gamePk", game_id)
            game_date = (
                pbp_data.get("gameData", {})
                .get("datetime", {})
                .get("officialDate", "unkown_date")
            )

            for play in all_plays:
                play["gamePk"] = game_pk
                play["officialDate"] = game_date

                yield play

            print(f"Successfully fetched and processed data for game {game_id}")

        except Exception as e:
            print(f"Error fetching or processing data for game {game_id}: {e}")


@dlt.source
def mlbam_pbp_source():
    """ """
    return mlbam_pbp_resource()


def run_mlbam_pipeline():
    pipeline = dlt.pipeline(
        pipeline_name="mlb_pbp_pipeline",
        destination="postgres",
        dataset_name="mlb_data",
    )
    load_info = pipeline.run(mlbam_pbp_source())
    print(load_info)


if __name__ == "__main__":
    run_mlbam_pipeline()
