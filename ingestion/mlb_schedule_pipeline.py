from datetime import datetime, timedelta
from typing import Dict, Any

import requests

import dlt


def get_mlb_schedule(dt: str) -> Dict[str, Any]:
    """Fetch schedule data for a single date from the MLB Stats API."""
    url = f"https://statsapi.mlb.com/api/v1/schedule?startDate={dt}&endDate={dt}&sportId=1"
    response = requests.get(url)
    response.raise_for_status()
    return response.json()


@dlt.resource(
    name="mlb_schedule", primary_key="fetched_date", write_disposition="merge"
)
def mlb_schedule_resource(start_date: str, end_date: str):
    """
    A DLT resource that yields schedule data for each date
    between start_date and end_date (inclusive).
    """
    current_date = datetime.strptime(start_date, "%Y-%m-%d")
    end_date_obj = datetime.strptime(end_date, "%Y-%m-%d")

    while current_date <= end_date_obj:
        dt_str = current_date.strftime("%Y-%m-%d")

        try:
            schedule_data = get_mlb_schedule(dt_str)

            schedule_data["fetched_date"] = dt_str

            yield schedule_data
        except Exception as e:
            print(f"Error fetching data for {dt_str}: {e}")

        current_date += timedelta(days=1)


@dlt.source
def mlb_schedule_source(
    start_date: str = dlt.config.value,
    end_date: str = dlt.config.value,
):
    """
    A DLT source that returns one or more resources.
    If you one only have one resource, just return mlb_schedule_resource(...).
    """
    return mlb_schedule_resource(start_date, end_date)


if __name__ == "__main__":
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=795)).strftime("%Y-%m-%d")

    pipeline = dlt.pipeline(
        pipeline_name="mlb_schedule_pipeline",
        destination="postgres",
        dataset_name="mlb_data",
    )

    load_info = pipeline.run(
        mlb_schedule_source(start_date=start_date, end_date=end_date)
    )

    print(load_info)
