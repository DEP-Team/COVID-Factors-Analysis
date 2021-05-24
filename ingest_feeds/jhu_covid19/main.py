"""
Tableau applied some engineering on the JHU datasets and released on data.world:
https://data.world/covid-19-data-resource-hub/covid-19-case-counts/workspace/file?filename=COVID-19+Activity.csv
* Note: This is a 145 MB file.


Otherwise, the original data sources are hostedo n JHU CSSE Github:
confirmed_source_url = "https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/" \
                       "csse_covid_19_time_series/time_series_covid19_confirmed_US.csv?raw=true"
deaths_source_url = "https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/" \
                    "csse_covid_19_time_series/time_series_covid19_deaths_US.csv?raw=true"
"""
import json
import logging
import os
from base64 import b64decode, b64encode
from datetime import datetime

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()
logging.basicConfig(level=logging.INFO)

source_url = "https://query.data.world/s/tkm63elprbahtxgring545j277t6s6"


def main(event, context):
    """Downloads US county COVID-19 case data from CSSE Github.
    Triggered from a message on a Cloud Pub/Sub topic.

    Args:
        data (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """
    current_time = datetime.utcnow()
    logging.info(f"Cloud Function was triggered on {current_time}")

    # message
    message_decoded = b64decode(event["data"].encode("ascii")).decode("ascii")
    message = json.loads(message_decoded) if message_decoded else {}

    logging.info(f"Downloading confirmed: {source_url}")
    df = (
        pd.read_csv(source_url)
            .dropna(subset=["COUNTY_FIPS_NUMBER"])
            .rename(columns={
                "REPORT_DATE": "date_id",
                "COUNTY_FIPS_NUMBER": "county_id",
                "PEOPLE_POSITIVE_CASES_COUNT": "positives_total",
                "PEOPLE_POSITIVE_NEW_CASES_COUNT": "positives_new",
                "PEOPLE_DEATH_NEW_COUNT":  "deaths_new",
                "PEOPLE_DEATH_COUNT": "deaths_total",
            })[[
                "date_id",
                "county_id",
                "positives_new",
                "deaths_new",
                "positives_total",
                "deaths_total",
            ]]
    )
    df["date_id"] = pd.to_datetime(df["date_id"]).dt.strftime("%Y%m%d")
    df["county_id"] = df["county_id"].astype(int).astype(str).str.zfill(5)
    df["county_date_id"] = df["county_id"] + df["date_id"]

    engine = create_engine(os.getenv("DATABASE_URI"))

    for chunk_idx in range(0, df.shape[0], 100_000):
        chunk_df = df[chunk_idx:chunk_idx + 100_000]
        logging.info(f"Inserting chunk: {chunk_idx}:{chunk_idx + chunk_df.shape[0]}")
        with engine.begin() as conn:
            chunk_df.to_sql("county_cases", con=conn, if_exists="append", index=False)

    df.to_csv("data/import/county_cases.csv", index=False)


if __name__ == "__main__":
    message = json.dumps({})
    data = {"data": b64encode(message.encode("ascii")).decode("ascii")}
    main(data, {})
