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
from base64 import b64decode, b64encode
from datetime import datetime

import pandas as pd
from dotenv import load_dotenv

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
                "PEOPLE_POSITIVE_CASES_COUNT": "total_cases",
                "PEOPLE_POSITIVE_NEW_CASES_COUNT": "new_cases",
                "PEOPLE_DEATH_NEW_COUNT":  "new_deaths",
                "PEOPLE_DEATH_COUNT": "total_deaths",
            })[[
                "county_id",
                "date_id",
                "new_cases",
                "new_deaths",
                "total_cases",
                "total_deaths",
            ]]
    )
    df["date_id"] = pd.to_datetime(df["date_id"]).dt.strftime("%Y%m%d")
    df["county_id"] = df["county_id"].astype(int).astype(str).str.zfill(5)
    df.loc[df["new_cases"] < 0, "new_deaths"] = 0
    df.loc[df["new_deaths"] < 0, "new_deaths"] = 0

    df.to_csv("data/import/county_cases.csv", index=False)


if __name__ == "__main__":
    message = json.dumps({})
    data = {"data": b64encode(message.encode("ascii")).decode("ascii")}
    main(data, {})
