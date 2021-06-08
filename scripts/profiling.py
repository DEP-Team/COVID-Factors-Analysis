"""
Create profiles for datasets

Requirements:
    `pip install pandas-profiling`

"""
from os import walk

import pandas as pd
from pandas_profiling import ProfileReport


if __name__ == "__main__":
    for dir, _, files in walk("data/import"):
        for file in files:
            if not file.endswith(".csv"):
                continue
            df = pd.read_csv(f"{dir}/{file}")
            profile = ProfileReport(df, title="Pandas Profiling Report", minimal=True)
            report_name = file.replace(".csv", "")
            profile.to_file(f"profiles/{file}.html")
