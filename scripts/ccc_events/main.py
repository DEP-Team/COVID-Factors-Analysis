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
import pandas as pd

ccc_uri = "https://github.com/nonviolent-action-lab/crowd-counting-consortium/blob/master/ccc_compiled.csv?raw=true"
acled_csv = "data/raw/acled_us_20200101_20210527.csv"
zip_fips_csv = "data/raw/zip_fips.csv"


def load_acled(engine):
    df = pd.read_csv(acled_csv)
    df = df[df["time_precision"] != 3] # monthly precision
    event = df[[
        "data_id",
        "event_date",
        "event_type",
        "sub_event_type",
        "actor1",
        "assoc_actor_1",
    ]]
    return df


def load_ccc(engine):
    df = pd.read_csv("data/raw/ccc_compiled.csv")
    df = df[~df["date"].isna()]
    df["fips_code"] = df["fips_code"].dropna().astype(int).astype(str).str.zfill(5)
    df["resolved_county"] = df["resolved_county"].str.replace("County", "")
    df["resolved_county"] = df["resolved_county"].str.strip()
