import logging
import os
from datetime import datetime

import pandas as pd
from dotenv import load_dotenv

load_dotenv()
bucket = os.getenv("BUCKET")

# CSVs are hosted on JHU CSSE Github
confirmed_source_url = "https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/" \
                       "csse_covid_19_time_series/time_series_covid19_confirmed_US.csv?raw=true"
deaths_source_url = "https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/" \
                    "csse_covid_19_time_series/time_series_covid19_deaths_US.csv?raw=true"

# CSVs written to GCS
# note: pandas can write to GCS directly using gcsfs library
confirmed_gcs_url = f"gs://{bucket}/jhu_covid19/confirmed.csv"
deaths_gcs_url= f"gs://{bucket}/jhu_covid19/deaths.csv"

storage_options = {
    "project": os.getenv("PROJECT"),
    "token": os.getenv("TOKEN"),
}

logging.basicConfig(level=logging.INFO)


def main(event, context):
    """Downloads US county COVID-19 case data from CSSE Github.
    Triggered from a message on a Cloud Pub/Sub topic.

    Args:
        data (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """
    current_time = datetime.utcnow()
    logging.info(f"Cloud Function was triggered on {current_time}")

    logging.info(f"Downloading confirmed: {confirmed_source_url}")
    confirmed_df = pd.read_csv(confirmed_source_url)

    logging.info(f"Downloading deaths: {deaths_source_url}")
    deaths_df = pd.read_csv(deaths_source_url)

    confirmed_df.to_csv(confirmed_gcs_url, storage_options=storage_options)
    logging.info(f"Stored confirmed: {confirmed_gcs_url}")

    deaths_df.to_csv(deaths_gcs_url, storage_options=storage_options)
    logging.info(f"Stored deaths: {deaths_gcs_url}")

    # verify file written
    df = pd.read_csv(confirmed_gcs_url, storage_options=storage_options)
    logging.info(f"confirmed shape: {df.shape})")


if __name__ == "__main__":
    main({}, {})
