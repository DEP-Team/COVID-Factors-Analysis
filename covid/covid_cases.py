import logging
from datetime import datetime

import requests
from gcsfs import GCSFileSystem


def ingest(
        fs: GCSFileSystem,
        current_time: datetime = None,
        bucket: str = None
):
    """Downloads US county COVID-19 case data from CSSE Github"""
    url = "https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/"\
          "csse_covid_19_time_series/time_series_covid19_confirmed_US.csv?raw=true"
    logging.info(f"Downloading: {url}")
    resp = requests.get(url)
    resp.raise_for_status()

    save_path = f"{bucket}/covid/covid_cases.csv"
    with fs.open(save_path, "wb") as fp:
        fp.write(resp.content)

    bytes_written = fs.du(save_path)
    logging.info(f"Bytes written: {bytes_written}")
    logging.info(f"Stored: {save_path}")
    return bytes_written > 0


if __name__ == "__main__":
    import os
    from dotenv import load_dotenv
    from gcsfs import GCSFileSystem

    load_dotenv()

    PROJECT = os.getenv("PROJECT")
    BUCKET = os.getenv("BUCKET")
    TOKEN = os.getenv("TOKEN")

    logging.basicConfig(
        level=logging.INFO,
        handlers=[logging.StreamHandler()])

    fs = GCSFileSystem(project=PROJECT, token=TOKEN)
    ingest(fs, bucket=BUCKET)
