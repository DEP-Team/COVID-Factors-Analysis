include .env

sched ?= "0 0 * * *"
message ?= "{}"
limit ?= 50

install:
	pip install virtualenv
	virtualenv venv
	source venv/bin/activate
	pip install -r requirements.txt

deploy:
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

schedule:
	gcloud scheduler jobs create pubsub ingest_feeds_$(name)_job\
		--schedule $(schedule)\
		--topic ingest_feeds_$(name)\
		--message-body $(message)

trigger:
	gcloud pubsub topics publish ingest_feeds_$(name)\
		--message "$(message)";

log:
	gcloud functions logs read --limit $(limit)