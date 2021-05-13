# COVID Factors Datasets
This repository is a catalog of datasets for COVID-19 Factors and ingestion scripts.

## Project layout

* Project is divided into tasks and data sources.
* Folders should have a `README.md` describing the tasks, sources, datasets.
* Python scripts for ingesting datasets.
* Sample datasets stored in Google Cloud Storage bucket.

```
|- README.md
|- census/
|  |- main.py
|  `- README.md
|- jhu_covid19/
|- social-gathering/
|- vaccinations/ 
|- gcloud-token.json
|- main.py
|- Makefile
`- requirements.txt
```

Note:
* `.env` are environment variables for project and bucket name and path to token. Set `TOKEN=cloud` to allow SDK to work its magic and when deploying to cloud.
* `gcloud-token.json` is the JSON private key for the `ingest-app` service account, but you can fill in with your own. Do NOT commit to git repo.
* `main.py` is the entry-point for Cloud Functions and CLI.
* `reuirements.txt` are the library dependencies to run any ingestion script.

### Describing sources

* Name of source
* Type of organization
* Methodology  
* Link to organization

### Describing datasets

* Name of dataset
* Summary description
* Subject area (e.g., census, covid, hospitalization, vaccines)
* How it should be downloaded (e.g., api, scrape)
* How frequently it’s updated
* Format of data (e.g., csv, json)
* Authentication (e.g., requires api key)
* Number of samples
* Date range of samples
* Format of geography dimension (e.g., lat lon, FIPS)
* Granularity of geography dimension (e.g., county, state)
* Granularity of time dimension (e.g., date)
* URL to dataset
* URL to documentation
* Detailed procedures for ingestion and transformation

## Development

Requirements:
* Python 3.7+ and Pip installed
* Python library: virtualenv
  ```sh
  pip install virtualenv
  ```
* [Github SSH key configured](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)
* Gcloud SDK CLI (Mac instructions: https://stackoverflow.com/questions/46144267/bash-gcloud-command-not-found-on-mac) 
  ```sh
  gcloud init
  ```
* Google service account with permission to GCS
* Gcloud authorization token ([Background](https://codeburst.io/google-cloud-authentication-by-example-1481b02292e4))
  ```sh
  gcloud init
  gcloud auth login
  ```

### Installing

* Clone project:
  ```sh
  git clone git@github.com:DEP-Team/COVID-Factors-Datasets.git
  cd COVID-Factors-Datasets
  ```
* Create virtual environment:
  ```sh
  virtualenv venv
  venv/bin/activate
  ```
* Install library dependencies:
  ```sh
  pip install -r requirements.txt 
  ```

### Running

```sh
python ingest_feeds/jhu_covid19/main.py
```

### Deploying

```sh
gcloud functions deploy ingest_feeds_$(name)\
    --entry-point main\
    --source ingest_feeds/$(name)\
    --runtime python37\
    --trigger-resource ingest_feeds_$(name)\
    --trigger-event google.pubsub.topic.publish\
    --timeout 540s\
    --set-env-vars PROJECT=${PROJECT}\
    --set-env-vars BUCKET=${BUCKET}\
    --set-env-vars TOKEN=cloud
```

### Scheduling

Run when creating or updating job schedule. Schedule format is in [crontab format](https://crontab.guru/). 
```sh
gcloud scheduler jobs create pubsub ingest_feeds_$(name)_job\
    --schedule "0 0 * * *"\
    --topic ingest_feeds_$(name)\
    --message-body "{}"
```

Example: ingesting JHU COVID-19 dataset daily.
```sh
gcloud scheduler jobs create pubsub ingest_feeds_$(name)_job\
    --schedule "0 0 * * *"\
    --topic ingest_feeds_$(name)\
    --message-body "{}"
```

Note:  --message-body uses the same "package.module:function" just how `python main.py` is called.

## References

* [How to schedule a recurring Python script on GCP](https://cloud.google.com/blog/products/application-development/how-to-schedule-a-recurring-python-script-on-gcp)
