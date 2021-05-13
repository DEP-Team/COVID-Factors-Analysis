# COVID Factors Datasets
This repository is a catalog of datasets for COVID-19 Factors and ingestion scripts.

## Project layout

* Project is divided into subject areas.
* Subject areas have a `README.md` describing the subject, sources, datasets.
* Python scripts responsible for ingesting datasets.
* Sample datasets are stored in Google Cloud Storage bucket.

```
|- README.md
|- census/
|  |- us_counties.py
|  `- README.md
|- covid/
|  |- jhu_county_summary.py
|  `- README.md
|- social-gathering/
|  | acled_events.py
|  `- README.md
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

Locally you can run function by invoking `main.py`, which has a `cli` method ready to accept an argument similar to how the script is invoked by PubSub. The path to the program is passed as an argument: `package_name.module_name:function_name`. For example, `covid.covid_cases:ingest`.

```sh
python main.py covid.covid_cases:ingest 
```

### Deploying

Deploying Cloud Function:

```sh
gcloud functions deploy ingest-feed --entry-point pubsub --runtime python37 --trigger-resource ingest-feed --trigger-event google.pubsub.topic.publish --timeout 540s
```

Scheduling: 
```sh
gcloud scheduler jobs create pubsub [TOPIC NAME] --schedule "* * * * *" --topic ingest-feed --message-body "[PACKAGE].[MODULE]:[FUNCTION]"
```

Only need to schedule job once. Only run if creating and updating job schedule. Schedule format is in [crontab format](https://crontab.guru/).

Scheduling Example: running `covid.covid_cases:ingest` once daily.
```sh
gcloud scheduler jobs create pubsub ingest-feed-covid-cases --schedule "0 0 * * *" --topic ingest-feed --message-body "covid.covid_cases:ingest"
```

Note:  --message-body uses the same "package.module:function" just how `python main.py` is called.

## References

* [How to schedule a recurring Python script on GCP](https://cloud.google.com/blog/products/application-development/how-to-schedule-a-recurring-python-script-on-gcp)
