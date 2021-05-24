"""
Census Tiger Cartographic Boundary Files
https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html

Description of Boundary Files:
https://www.census.gov/programs-surveys/geography/technical-documentation/naming-convention/cartographic-boundary-file.html

Data Dictionary (Appendix I-2, pg. 131)
https://www2.census.gov/geo/pdfs/maps-data/data/tiger/tgrshp2020/TGRSHP2020_TechDoc_F-R.pdf
* STATEFP - Current State FIPS code
* COUNTYFP - Current County FIPS code
* COUNTYNS - ANSI feature code for the county or equivalent feature
* AFFGEOID -
* GEOID - County identifier; a concatenation of Current state FIPS
code and county FIPS code
* NAME - Current county name
* LSAD - Legal/Statistical Area Description
* ALAND - Current land area
* AWATER - Current water area

For state:
* STATENS - ANSI feature code for the state or equivalent entity
* STUSPS - Current United States Postal Service state abbreviation

* AFF GEOID is deprecated: https://www.census.gov/data/what-is-data-census-gov/guidance-for-data-users/transition-from-aff.html

"""
import json
import logging
from base64 import b64decode, b64encode
from datetime import datetime

import geopandas as gpd
import pandas as pd
import requests
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()
logging.basicConfig(level=logging.INFO)


def fetch_entity(ss: str, entity: str, year=2019, rr="20m"):
    """
    Census Tiger documentation: https://www2.census.gov/geo/tiger/GENZ2019/2019_file_name_def.pdf
    :param ss:
    :param entity:
    :param year:
    :param rr:
    :return:
    """
    filename = f"cb_{year}_{ss}_{entity}_{rr}".format(ss=ss, entity=entity, year=str(year), rr=rr)
    url = f"https://www2.census.gov/geo/tiger/GENZ2019/shp/{filename}.zip?ts={datetime.now()}"
    response = requests.get(url, stream=True)
    filepath = f"data/raw/{filename}.zip"
    with open(filepath, "wb") as fh:
        for chunk in response.iter_content(chunk_size=512):
            if chunk:
                fh.write(chunk)
    return gpd.read_file(filepath)


def load_states(engine):
    states = (
        fetch_entity("us", "state")
            .sort_values("STATEFP")
            .reset_index()
            .rename(columns={
                "GEOID": "state_id",
                "NAME": "name",
                "STUSPS": "abbrev",
                "STATEFP": "state_fips",
                "STATENS": "feature_code",
                "LSAD": "lsad_code",
                "ALAND": "land_area",
                "AWATER": "water_area"
            })
    )
    states = states[[
        "state_id",
        "name",
        "abbrev",
        "state_fips",
        "feature_code",
        "lsad_code",
        "land_area",
        "water_area"
    ]]
    
    with engine.begin() as conn:
        states.to_sql("state", con=conn, if_exists="append", index=False)

    # create CSV for posterity
    states.to_csv("data/import/state.csv", index=False)


def load_counties(engine):
    counties = (
        fetch_entity("us", "county")
            .sort_values("COUNTYFP")
            .reset_index()
            .rename(columns={
                "GEOID": "county_id",
                "NAME": "name",
                "STATEFP": "state_fips",
                "COUNTYFP": "county_fips",
                "COUNTYNS": "feature_code",
                "LSAD": "lsad_code",
                "ALAND": "land_area",
                "AWATER": "water_area",
        })
    )
    counties = counties[[
        "county_id",
        "name",
        "county_fips",
        "state_fips",
        "feature_code",
        "lsad_code",
        "land_area",
        "water_area",
    ]]

    with engine.begin() as conn:
        counties.to_sql("county", con=conn, if_exists="append", index=False)

    counties.to_csv("data/import/county.csv", index=False)


def load_csas(engine):
    """
    CSA map: https://www2.census.gov/geo/maps/metroarea/us_wall/Mar2020/CSA_WallMap_Mar2020.pdf
    :param engine:
    :return:
    """
    url = "https://www2.census.gov/programs-surveys/metro-micro/geographies/reference-files/2020/delineation-files/list1_2020.xls"
    df = (
        pd.read_excel(url, skiprows=2, skipfooter=4)
          .rename(columns={
                "CSA Code": "csa_id",
                "Metropolitan/Micropolitan Statistical Area": "type",
                "CSA Title": "name",
                "FIPS State Code": "state_fips",
                "FIPS County Code": "county_fips",
                "Central/Outlying County": "centrality",
            })
          .dropna(subset=["csa_id"])
          .astype({
                "csa_id": "int32",
                "state_fips": "object",
                "county_fips": "object",
            })
    )
    df["county_fips"] = df["county_fips"].apply(lambda cell: f"{cell:03}")
    df["state_fips"] = df["state_fips"].apply(lambda cell: f"{cell:02}")
    df["county_id"] = df["state_fips"] + df["county_fips"]

    csa_df = df[[
        "csa_id",
        "name",
        "type",
    ]].drop_duplicates("csa_id")

    county_csa_df = df[[
        "county_id",
        "csa_id",
        "centrality",
    ]]

    with engine.begin() as conn:
        csa_df.to_sql("csa", con=conn, if_exists="append", index=False)
        county_csa_df.to_sql("county_csa", con=conn, if_exists="append", index=False)

    csa_df.to_csv("data/import/csa.csv", index=False)
    county_csa_df.to_csv("data/import/county_csa.csv", index=False)


def main(event, context):
    """Downloads Census Tiger Files and loads into MySQL tables.
    Triggered from a message on a Cloud Pub/Sub topic.

    Args:
        data (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """
    current_time = datetime.utcnow()
    logging.info(f"Cloud Function was triggered on {current_time}")

    # message
    #message_decoded = b64decode(event["data"].encode("ascii")).decode("ascii")
    #message = json.loads(message_decoded) if message_decoded else {}

    engine = create_engine(os.getenv("DATABASE_URI"))
    load_states(engine)
    load_counties(engine)
    load_csas(engine)


if __name__ == "__main__":
    #message = json.dumps({})
    #data = {"data": b64encode(message.encode("ascii")).decode("ascii")}
    #main(data, {})
    pass
