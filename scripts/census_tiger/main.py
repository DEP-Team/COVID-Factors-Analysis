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

Metropolitan Areas: CBSA and Consolidated Statistical Areas (CSA) FIPS codes:
https://www2.census.gov/programs-surveys/cps/methodology/2015%20Geography%20Cover.pdf

Note: HHP Survey MSA is the CBSA.
From the survey design: https://www2.census.gov/programs-surveys/demo/technical-documentation/hhp/2020_HPS_Background.pdf
    "The Household Pulse Survey is designed to produce estimates at three different geographical levels. The
    first level, the lowest geographical area, is for the 15 largest MSAs. The second level of geography is for
    state-level estimates for each of the 50 states and the District of Columbia, and the final level geography
    are national-level estimates.
    "Sampling rates within each county are determined at the state level. If a county is part of an MSA and
    requires more sample at the county level based on the MSA sampling size requirements, then more
    sample will be included in the MSA counties to satisfy the MSA level sample size requirements. An
    example is the Washington-Arlington-Alexandria, DC-VA-MD-WV MSA. In this MSA the required
    sampling interval is smaller than the Maryland sampling interval; thus, requiring more sample in the
    MSA counties of Maryland compared to the balance of the state. These sampling rates are the basis for
    the base weights of the sample."

In the example, "Washington-Arlington-Alexandria, DC-VA-MD-WV" is:
    * CBSA FIPS code: 47900 - Washington-Arlington-Alexandria, DC-VA-MD-WV
    * CSA FIPS code: 548 - Washington-Baltimore-Arlington, DC-MD-VA-WV-PA
"""
import json
import logging
import os
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
    
    #with engine.begin() as conn:
    #    states.to_sql("state", con=conn, if_exists="append", index=False)

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

    #with engine.begin() as conn:
    #    counties.to_sql("county", con=conn, if_exists="append", index=False)

    counties.to_csv("data/import/county.csv", index=False)


def load_msas(engine):
    """
    CSA map: https://www2.census.gov/geo/maps/metroarea/us_wall/Mar2020/CSA_WallMap_Mar2020.pdf
    :param engine:
    :return:
    """
    url = "https://www2.census.gov/programs-surveys/metro-micro/geographies/reference-files/2020/delineation-files/list1_2020.xls"
    df = (
        pd.read_excel(url, skiprows=2, skipfooter=4)
          .rename(columns={
                "CBSA Code": "msa_id",
                "CBSA Title": "msa_name",
                "Metropolitan/Micropolitan Statistical Area": "msa_type",
                "CSA Code": "csa_id",
                "CSA Title": "csa_name",
                "FIPS State Code": "state_fips",
                "FIPS County Code": "county_fips",
                "Central/Outlying County": "centrality",
            })
          .astype({
                "state_fips": "object",
                "county_fips": "object",
            })
    )
    df["county_fips"] = df["county_fips"].apply(lambda cell: f"{cell:03}")
    df["state_fips"] = df["state_fips"].apply(lambda cell: f"{cell:02}")
    df["county_id"] = df["state_fips"] + df["county_fips"]
    df["msa_fips"] = df["msa_id"]
    df["csa_fips"] = df["csa_id"]

    csa_df = df.rename(
        columns={
            "csa_name": "name",
        }).dropna(
            subset=["csa_id"]
        ).astype({
            "csa_id": "int32",
            "csa_fips": "int32",
        }).astype({
            "csa_fips": "str",
        })[[
            "csa_id",
            "csa_fips",
            "name",
        ]].drop_duplicates("csa_id")

    msa_df = df.rename(
        columns={
            "msa_name": "name",
            "msa_type": "type",
        }).dropna(
            subset=["msa_id"]
        ).astype({
            "msa_id": "int32"
        })[[
            "msa_id",
            "msa_fips",
            "name",
            "type",
        ]].drop_duplicates("msa_id")

    df["csa_id"] = df["csa_id"].apply(lambda v: None if pd.isna(v) else f"{int(v):0>3}")
    county_msa_df = df[[
        "county_id",
        "msa_id",
        "csa_id",
        "centrality",
    ]]

    #with engine.begin() as conn:
    #    msa_df.to_sql("msa", con=conn, if_exists="append", index=False)
    #    csa_df.to_sql("csa", con=conn, if_exists="append", index=False)
    #    county_msa_df.to_sql("county_msa", con=conn, if_exists="append", index=False)

    msa_df.to_csv("data/import/msa.csv", index=False, na_rep="NULL")
    csa_df.to_csv("data/import/csa.csv", index=False, na_rep="NULL")
    county_msa_df.to_csv("data/import/county_msa.csv", index=False, na_rep="NULL")


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
    load_msas(engine)


if __name__ == "__main__":
    message = json.dumps({})
    data = {"data": b64encode(message.encode("ascii")).decode("ascii")}
    main(data, {})
