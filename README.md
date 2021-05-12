# COVID Factors Datasets
This repository will function as a catalog of datasets for COVID Factors.

## Dataset layout

* Project is divided into subject areas.
* Each subject area should have a `README.md` describing the dataset, how to ingest and what transformations should take place.
* Sample datasets are stored in a subject area folder.

```
|- README.md
|- census/
|  |- README.md
|  `- sample.csv 
|- covid/
   |- README.md
   |- covid_cases.csv
   |- covid_testing.csv
   `- covid_hospitalization.csv
|- social-gathering/
`- vaccinations/ 
```

## Dataset metadata
Maintain metadata about each datasets:
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

## Notes
Requirements:
* Install Python, Pip and Poetry
* Create Google service account with permission to GCS and generate JSON file
* Install Gcloud (Mac: https://stackoverflow.com/questions/46144267/bash-gcloud-command-not-found-on-mac)

### Creating a Cloud Function
Walkthrough: https://cloud.google.com/blog/products/application-development/how-to-schedule-a-recurring-python-script-on-gcp
1. Create Python file and function
2. Deploy function: 
   ```
   gcloud functions deploy ingest-feed --entry-point main --runtime python37 --trigger-resource ingest-feed --trigger-event google.pubsub.topic.publish --timeout 540s
   ```
3. Create schedule. NOTE: JOB should have its own name, and MESSAGE BODY should be the location of module and function.
   ```
   gcloud scheduler jobs create pubsub [TOPIC NAME] --schedule "* * * * *" --topic ingest-feed --message-body "[PACKAGE].[MODULE]:[FUNCTION]"
   ```
   Example:
   ```
   gcloud scheduler jobs create pubsub ingest-feed-covid-cases --schedule "* * * * *" --topic ingest-feed --message-body "covid.covid_cases:ingest"
   ```