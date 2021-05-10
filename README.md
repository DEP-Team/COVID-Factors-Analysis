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
