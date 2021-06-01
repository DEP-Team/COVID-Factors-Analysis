"""
CCC contains Presidential campaign rallies
CCC does not contain right-wing rallies (e.g., events in Portland)


Github repo for dataset: https://github.com/nonviolent-action-lab/crowd-counting-consortium
Data dictionary: https://github.com/nonviolent-action-lab/crowd-counting-consortium/blob/master/ccc_data_dictionary.md

Note on accuracy:
https://willopines.wordpress.com/2014/03/03/no-more-fountains-of-youthpots-o-gold-conceptualization-and-events-data-part-1/
Validity of Conflict data: https://www.jstor.org/stable/2117734?seq=1

Reports:
"A YEAR OF COVID-19: THE PANDEMIC’S IMPACT ON GLOBAL CONFLICT AND DEMONSTRATION TRENDS"
https://acleddata.com/2021/04/01/a-year-of-covid-19-the-pandemics-impact-on-global-conflict-and-demonstration-trends/

ACLED codebook: https://acleddata.com/acleddatanew/wp-content/uploads/dlm_uploads/2019/01/ACLED_Codebook_2019FINAL.docx.pdf
"""
import hashlib
import re
import uuid

import geopandas as gpd
import numpy as np
import pandas as pd

ccc_uri = "https://github.com/nonviolent-action-lab/crowd-counting-consortium/blob/master/ccc_compiled.csv?raw=true"
acled_csv = "data/raw/acled_us_20200101_20210527.csv"
zip_fips_csv = "data/raw/zip_fips.csv"


def load_acled():
    acled_df = pd.read_csv(acled_csv, parse_dates=["event_date"])
    acled_df = acled_df[acled_df["time_precision"] != 3]  # leave out monthly precision
    acled_gdf = gpd.GeoDataFrame(
        acled_df, geometry=gpd.points_from_xy(acled_df["longitude"], acled_df["latitude"]))
    county_gdf = gpd.read_file("data/import/county.geojson")
    gdf = gpd.sjoin(acled_gdf, county_gdf, how="inner", op="intersects")
    gdf["event_type_slug"] = gdf["sub_event_type"].str.replace(r"[^\w]", "").str.lower()
    gdf["interaction_id"] = gdf["interaction"]
    gdf["source_count"] = gdf["source"].apply(lambda source: len(source.split("; ")))
    gdf["event_id"] = gdf["data_id"]
    gdf["date_id"] = gdf["event_date"].dt.strftime("%Y%m%d")

    # build event_type
    event_type_df = (
        gdf[[
            "event_type",
            "sub_event_type",
            "event_type_slug",
        ]]
        .drop_duplicates()
        .rename_axis("event_type_id")
        .reset_index()
    )
    event_type_df["event_type_id"] = np.arange(1, len(event_type_df) + 1)
    event_type_df["general_type"] = event_type_df["event_type"].apply(
        lambda event_type: "Violent events" if event_type in ("Battles", "Explosions/Remote violence", "Violence against civilians")
            else "Demonstrations" if event_type in ("Protests", "Riots")
            else "Non-violent actions" if event_type in "Strategic developments"
            else "Other")
    gdf = gdf.merge(event_type_df[["event_type_id", "event_type_slug"]], how="left", on="event_type_slug")
    event_type_df.to_csv("data/import/event_type.csv", index=False, na_rep="NULL")

    # build event_actor
    event_actor_df = (
        pd.concat([
            gdf.assign(
                actor=gdf["actor1"],
                actor_type_id=gdf["inter1"],
                group_num=1,
                affiliation="primary"),
            gdf.assign(
                actor=gdf["actor2"],
                actor_type_id=gdf["inter2"],
                group_num=2,
                affiliation="primary")[
                gdf["inter2"] > 0],
            gdf.assign(
                actor=gdf["assoc_actor_1"],
                actor_type_id=gdf["inter1"],
                group_num=1,
                affiliation="associated")[
                ~gdf["assoc_actor_1"].isna()],
            gdf.assign(
                actor=gdf["assoc_actor_2"],
                actor_type_id=gdf["inter2"],
                group_num=2,
                affiliation="associated")[
                (gdf["inter2"] > 0) & (~gdf["assoc_actor_2"].isna())],
        ])
    )
    event_actor_df["actor"] = event_actor_df["actor"].fillna("").str.split("; ")
    event_actor_df = event_actor_df.explode("actor")
    event_actor_df = event_actor_df.astype({
        "actor": "category",
        "actor_type_id": "category",
        "group_num": "category",
        "affiliation": "category",
    })

    event_actor_df["actor_id"] = event_actor_df["actor"]
    event_actor_df["actor_name"] = event_actor_df["actor"]
    # event_actor_df["actor_id"] = event_actor_df["actor_id"].cat.remove_categories("")
    event_actor_df["actor_id"].cat.categories = np.arange(1, len(event_actor_df["actor_id"].cat.categories) + 1)

    actor_df = (
        event_actor_df[[
            "actor_id",
            "actor_name",
        ]]
        .dropna()
        .drop_duplicates()
    )
    actor_df["actor_slug"] = actor_df["actor_name"].str.lower().str.replace(r"[^\w]", "")
    actor_df.to_csv("data/import/actor.csv", index=False, na_rep="NULL")

    event_actor_df = event_actor_df[[
        "event_id",
        "actor_id",
        "actor_type_id",
        "group_num",
        "affiliation",
    ]]
    event_actor_df.to_csv("data/import/event_actor.csv", index=False, na_rep="NULL")

    # extract more metadata about event:
    gdf["size"] = gdf["notes"].apply(lambda notes: re.findall(r"\[size=(.*)\]", notes))
    gdf["size"] = gdf["size"]\
        .apply(lambda size: size[0] if len(size) > 0 else "")\
        .apply(lambda size: size.replace("hundred", "100")
                                .replace("thousand", "1000")
                                .replace("dozen", "12")
                                .replace("group", "5")
                                .replace("several", "")
                                .replace("handful", "5")
                                .replace("sizeable", "10"))\
        .apply(lambda size: re.findall(r"(\d+)", size))\
        .apply(lambda size: int(size[0]) if len(size) > 0 else np.nan)
    gdf["size_scale"] = gdf["size"].apply(lambda size: int(np.floor(np.log10(size))) if not pd.isna(size) else 0)

    gdf["tags"] = gdf["notes"]\
        .apply(lambda notes: re.findall(r"\[([\w\s\-]+)\]", notes))\
        .apply(lambda tags: tags[0].replace("-", " ") if tags else None)

    gdf["armed_presence"] = gdf["tags"].str.contains("armed").fillna("0").astype(int)
    gdf["counter_protest"] = gdf["tags"].str.contains("counter").fillna("0").astype(int)
    gdf["source_ccc"] = gdf["source"].str.contains("Crowd Counting Consortium").fillna("0").astype(int)

    event_df = gdf[[
        "event_id",
        "county_id",
        "date_id",
        "event_type_id",
        "interaction_id",
        "fatalities",
        "size",
        "size_scale",
        "tags",
        "notes",
        "armed_presence",
        "counter_protest",

        # datasource metadata
        "location",
        "geo_precision",
        "time_precision",
        "source",
        "source_scale",
        "source_count",
        "source_ccc",
    ]]
    event_df.to_csv("data/import/acled_event.csv", index=False, na_rep="NULL")


def create_uuid(id: str, salt: str):
    msg = hashlib.md5()
    msg.update(f"{salt}:{id}".encode("utf-8"))
    return str(uuid.UUID(msg.hexdigest()))


def load_ccc(engine):
    ccc_df = pd.read_csv("data/raw/ccc_compiled.csv", parse_dates="date")
    ccc_df = ccc_df[~ccc_df["date"].isna()]
    ccc_df = ccc_df[ccc_df["online"] == 0]
    ccc_gdf = gpd.GeoDataFrame(
    ccc_df, geometry=gpd.points_from_xy(ccc_df["lon"], ccc_df["lat"]))
    county_gdf = gpd.read_file("data/import/county.geojson")
    gdf = gpd.sjoin(ccc_gdf, county_gdf, how="inner", op="intersects")

    gdf["event_id"] = gdf.apply(lambda row: create_uuid(f"{row['date']}_{row['county_id']}_{row['locality']}", ""),
                                axis=1)


    event_df = gdf[[
        "event_id",
        "county_id",
        "date",
        "event_type_id",
        "interaction_id",
        "fatalities",
        "size",
        "size_scale",
        "tags",
        "notes",
        "armed_presence",
        "counter_protest",

        "location_detail",


        "location",
        "geo_precision",
        "time_precision",
        "source",
        "source_scale",
        "source_count",
    ]]


if __name__ == "__main__":
    load_acled()
