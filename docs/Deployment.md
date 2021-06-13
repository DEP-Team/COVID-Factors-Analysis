# Deployment

This project was designed to maintain a daily-updating database. Scripts
are deployed as Google Cloud Functions, which are triggered by Cloud Scheduler
via Pub Sub. For more information, see the PowerPoint presentation.

## Project layout

* Project is divided into tasks and data sources.
* Folders are containers for [Cloud Functions with PubSub trigger](https://cloud.google.com/functions/docs/calling/pubsub) and contain a Python script and requirements file.
* Folders should have a `README.md` describing the tasks, sources, datasets.
* Sample datasets stored in Google Cloud Storage bucket.

```
|- README.md
|- jhu_covid19/
|  |- main.py
|  |- requirements.txt
|  `- README.md
|- social-gathering/
|- vaccinations/ 
|- gcloud-token.json
|- Makefile
```

Note:
* `.env` are environment variables for project and bucket name and path to token.
* `gcloud-token.json` is the JSON private key for the `ingest-app` service account, but you can fill in with your own.
* `Makefile` contains recipes to deploy and schedule Cloud Functions
* Cloud Function expects a Python file named `main.py` with a function named `main()`.

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
* Setup local MySQL database: make sure that environment variables are set correctly in `.env` and [Make is installed](https://stackoverflow.com/a/32127632) (Windows only).
```sh
make createdb importdb createdw loaddw
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

## CloudSQL
### Getting setup with Cloud SQL:
* Create Cloud SQL instance
* Set instance flag: `log_bin_trust_function_creators=1`
* Create database and users
* Whitelist network (home IPs)
* Run `make createdb importdb createdw loaddw`

## References

* [How to schedule a recurring Python script on GCP](https://cloud.google.com/blog/products/application-development/how-to-schedule-a-recurring-python-script-on-gcp)
