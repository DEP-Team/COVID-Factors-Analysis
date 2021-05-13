
install:
	pip install virtualenv
	virtualenv venv
	source venv/bin/activate
	pip install -r requirements.txt

deploy:
	gcloud functions deploy ingest-feed\
		--entry-point pubsub\
		--runtime python37\
		--trigger-resource ingest-feed\
		--trigger-event google.pubsub.topic.publish\
		--timeout 540s

schedule:
	gcloud scheduler jobs create pubsub $(jobname) \
		--schedule "0 0 * * *"\
		--topic ingest-feed\
		--message-body $(prog)
