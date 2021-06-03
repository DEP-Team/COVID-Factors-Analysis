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
    ccc_df = pd.read_csv("data/raw/ccc_compiled.csv", parse_dates=["date"])
    ccc_df = ccc_df[~ccc_df["date"].isna()]
    ccc_df = ccc_df[~ccc_df["type"].isna()]
    ccc_df = ccc_df[ccc_df["online"] == 0]
    ccc_gdf = gpd.GeoDataFrame(
    ccc_df, geometry=gpd.points_from_xy(ccc_df["lon"], ccc_df["lat"]))
    county_gdf = gpd.read_file("data/import/county.geojson")
    gdf = gpd.sjoin(ccc_gdf, county_gdf, how="inner", op="intersects")

    gdf["event_id"] = gdf.apply(
        lambda row: create_uuid(f"{row['date']}_{row['county_id']}_{row['locality']}_{row['location_detail']}", ""),
        axis=1)
    gdf["date_id"] = gdf["date"].dt.strftime("%Y%m%d")
    gdf["event_type_id"] = 1  # peaceful protest
    gdf["protest_type"] = gdf["type"].str.replace(",", ";").str.split(";")
    gdf["counter_protest"] = gdf["type"].str.contains("counter").astype(int)
    gdf["actors"] = gdf["actors"].fillna("general protestors")
    gdf["size"] = gdf["size_mean"].fillna(0)
    gdf["size_scale"] = gdf["size_cat"].fillna(0)
    gdf["notes"] = gdf["misc"]
    gdf["armed_presence"] = np.nan

    event_groups = gdf.groupby("event_id")["valence"].nunique().rename("group_count").reset_index()
    gdf = pd.merge(gdf, event_groups, on="event_id")
    gdf["riot"] = ((gdf["property_damage_any"].astype(int) + gdf["chemical_agents"].fillna(0).astype(int)) > 0).astype(int)

    gdf["interaction_id"] = gdf.apply(
        lambda row:\
            50 if row["group_count"] == 1 and row["riot"] == 1 else  # rioter sole
            60 if row["group_count"] == 1 and row["riot"] == 0 else  # protester sole
            55 if row["group_count"] > 1 and row["riot"] == 1 else   # rioter vs rioter
            66 if row["group_count"] > 1 and row["riot"] == 0 else   # protester vs protestor
            60,  # Protester sole
        axis=1)

    gdf["source_count"] = 0
    gdf["source"] = ""
    for source_idx in range(1, 26):
        gdf["source_count"] += (~gdf[f"source_{source_idx}"].isna()).astype(int)
        gdf["source"] += "; " + gdf[f"source_{source_idx}"].astype(str)
    gdf["source"] = gdf["source"].apply(lambda source: str(source).replace("nan", "").split("; "))
    gdf["source"] = gdf["source"].apply(lambda source: "; ".join(filter(None, source)))

    event_df = gdf[[
        "event_id",
        "county_id",
        "date_id",
        "event_type_id",
        "interaction_id",
        # "size",
        # "size_scale",
        "notes",
        "counter_protest",

        "location_detail",
        "macroevent",

        "arrests",
        # "arrests_any",
        "injuries_crowd",
        # "injuries_crowd_any",
        "injuries_police",
        # "injuries_police_any",
        "property_damage",
        # "property_damage_any",
        # "chemical_agents",

        "source",
        # "source_count",
    ]]
    event_sums_df = gdf.groupby("event_id").agg({
        "size": "sum",
        "size_scale": "sum",
        "arrests_any": "max",
        "injuries_crowd_any": "max",
        "injuries_police_any": "max",
        "property_damage_any": "max",
        "chemical_agents": "max",
        "source_count": "sum",
    })
    event_df = pd.merge(event_df, event_sums_df, on="event_id")
    event_df = gdf[[
        "event_id",
        "county_id",
        "date_id",
        "event_type_id",
        "interaction_id",
        "size",
        "size_scale",
        "notes",
        "counter_protest",
        "location_detail",
        "macroevent",
        "arrests",
        "arrests_any",
        "injuries_crowd",
        "injuries_crowd_any",
        "injuries_police",
        "injuries_police_any",
        "property_damage",
        "property_damage_any",
        "chemical_agents",
        "source",
        "source_count",
    ]]
    event_df["size_scale"] = np.floor(np.log10(event_df["size"] + 9)).astype(int)
    event_df = event_df.drop_duplicates(subset=["event_id"])
    event_df.to_csv("data/import/ccc_event.csv", index=False, na_rep="NULL")

    gdf["actor"] = gdf["actors"].fillna("general protesters").str.split("; ")
    gdf = gdf.explode("actor")
    gdf["actor_slug"] = gdf["actor"].astype(str).str.lower().str.replace(r"[^\w]", "")
    gdf["actor_type_id"] = gdf["riot"].apply(lambda riot: 5 if riot else 6)
    gdf["valence"] = gdf["valence"].fillna(0).apply(lambda valence: 3 if valence == 0 else valence)  # 3 = other
    gdf["group_num"] = gdf.apply(
        lambda row:
            1 if row["group_count"] == 1 else int(row["valence"]),
        axis=1
    )
    gdf["affiliation"] = "primary"

    actor_count = gdf["actor_slug"].value_counts().rename("actor_count").rename_axis("actor_slug").reset_index()
    gdf = pd.merge(gdf, actor_count, on="actor_slug")
    gdf.loc[gdf["actor_count"] < 5, "actor_slug"] = "generalprotesters"

    gdf = gdf.astype({
        "actor_slug": "category",
        "actor_type_id": "category",
        "group_num": "category",
        "affiliation": "category",
    })

    gdf["actor_name"] = gdf["actor"]
    gdf["actor_id"] = gdf["actor_slug"]
    gdf["actor_id"].cat.categories = np.arange(1, len(gdf["actor_id"].cat.categories) + 1)

    actor_df = (
        gdf[[
            "actor_id",
            "actor_name",
            "actor_slug",
        ]]
        .dropna()
        .drop_duplicates(subset=["actor_id"])
    )
    actor_df.to_csv("data/import/ccc_actor.csv", index=False, na_rep="NULL")

    event_actor_df = gdf[[
        "event_id",
        "actor_id",
        "actor_type_id",
        "group_num",
        "claims",
        "valence",
    ]]
    event_actor_df = event_actor_df.drop_duplicates(subset=["event_id", "actor_id", "group_num"])
    event_actor_df.to_csv("data/import/ccc_event_actor.csv", index=False, na_rep="NULL")

    gdf["issues"] = gdf["issues"].fillna("").str.split("; ")
    gdf = gdf.explode("issues")
    gdf["issue_name"] = gdf["issues"]
    gdf["issue_slug"] = gdf["issue_name"].str.lower().str.replace(r"[^\w]", "")
    gdf["issue_id"] = gdf["issue_slug"].astype("category")
    gdf["issue_id"].cat.categories = np.arange(1, len(gdf["issue_id"].cat.categories) + 1)

    issue_df = (
        gdf[[
            "issue_id",
            "issue_name",
        ]]
        .dropna()
        .drop_duplicates()
    )
    issue_df.to_csv("data/import/issue.csv", index=False, na_rep="NULL")

    event_issue_df = gdf[[
        "event_id",
        "issue_id",
    ]].drop_duplicates()
    event_issue_df.to_csv("data/import/ccc_event_issue.csv", index=False, na_rep="NULL")

    gdf = gdf.explode("protest_type")
    gdf["protest_type_name"] = gdf["protest_type"]
    gdf["protest_type_slug"] = gdf["protest_type_name"].str.lower().str.replace(r"[^\w]", "")
    gdf["protest_type_id"] = gdf["protest_type_slug"].astype("category")
    gdf["protest_type_id"].cat.categories = np.arange(1, len(gdf["protest_type_id"].cat.categories) + 1)

    protest_type_df = (
        gdf[[
            "protest_type_id",
            "protest_type_name",
        ]]
        .dropna()
        .drop_duplicates(subset=["protest_type_id"])
    )
    protest_type_df["protest_type_slug"] = protest_type_df["protest_type_name"].str.lower().str.replace(r"[^\w]", "")
    protest_type_df.to_csv("data/import/protest_type.csv", index=False, na_rep="NULL")

    event_protest_type_df = gdf[[
        "event_id",
        "protest_type_id",
    ]].drop_duplicates()
    event_issue_df.to_csv("data/import/ccc_event_protest_type.csv", index=False, na_rep="NULL")


if __name__ == "__main__":
    load_acled()
