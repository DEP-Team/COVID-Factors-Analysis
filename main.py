import base64
import logging
import os
import importlib
from datetime import datetime
from typing import Any

import click
import gcsfs
from dotenv import load_dotenv

load_dotenv()

PROJECT = os.getenv("PROJECT")
BUCKET = os.getenv("BUCKET")
TOKEN = os.getenv("TOKEN")


def pubsub(data: Any, event: Any):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Calls an ingestion function based on message.

    Args:
        data (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """
    logging.info(f"MAIN triggered: d={data}, c={event}")
    try:
        current_time = datetime.utcnow()
        logging.info(f"Cloud Function was triggered on {current_time}")
        try:
            fs = gcsfs.GCSFileSystem(project=PROJECT, token=TOKEN)
            target = base64.b64decode(data["data"].encode("ascii")).decode("ascii")
            target_module, target_method = target.split(":")
            logging.info(f"Calling method: {target_module}.{target_method}")
            ingest_module = importlib.import_module(target_module)
            ingest_func = getattr(ingest_module, target_method)
            ingest_func(fs, current_time, bucket=BUCKET)
        except Exception as error:
            logging.error(f"Query failed due to {error}")
            raise
    except Exception as error:
        logging.error(f"Query failed due to {error}")
        raise


@click.command()
@click.argument("prog")
def cli(prog: str):
    pubsub({"data": base64.b64encode(prog.encode("ascii")).decode("ascii")}, {})


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        handlers=[logging.StreamHandler()])

    cli()
