include .env

sched ?= "0 0 * * *"
message ?= "{}"
limit ?= 50

install:
	pip install virtualenv
	virtualenv venv
	source venv/bin/activate

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

db:
	rm -rf build;
	mkdir -p build;
	touch build/makedb.sql;
	cat sql/date/staging-ddl.sql >> build/makedb.sql;
	cat sql/census_tiger/staging-ddl.sql >> build/makedb.sql;
	cat sql/census_hhp/staging-ddl.sql >> build/makedb.sql;
	cat sql/census_demographics/staging-ddl.sql >> build/makedb.sql;
	cat sql/jhu_covid19/staging-ddl.sql >> build/makedb.sql;
	mysql -u root -p -D covid < build/makedb.sql;
	rm -rf build;

import:
	mysql -u root -p -D covid < sql/date/staging-dml.sql;
	mysqlimport --password --local\
		--ignore-lines 1\
		--lines-terminated-by "\n"\
		--fields-terminated-by ","\
		--fields-optionally-enclosed-by '"'\
		covid\
		data/import/csa.csv\
		data/import/msa.csv\
		data/import/state.csv\
		data/import/county.csv\
		data/import/county_msa.csv\
		data/import/county_demographics.csv\
		data/import/characteristic_type.csv\
		data/import/characteristic.csv\
		data/import/question.csv\
		data/import/response.csv\
		data/import/region.csv\
		data/import/survey.csv\
		data/import/survey_response.csv\
		data/import/county_cases.csv;

dw:
	rm -rf build;
	mkdir -p build;
	touch build/makedw.sql;
	cat sql/date/dw-ddl.sql >> build/makedw.sql;
	cat sql/census_tiger/dw-ddl.sql >> build/makedw.sql;
	cat sql/census_hhp/dw-ddl.sql >> build/makedw.sql;
	cat sql/census_demographics/dw-ddl.sql >> build/makedw.sql;
	cat sql/jhu_covid19/dw-ddl.sql >> build/makedw.sql;
	mysql -u root -p -D covid < build/makedw.sql;
	rm -rf build;

etl:
	rm -rf build;
	mkdir -p build;
	touch build/etldw.sql;
	cat sql/date/dw-dml.sql >> build/etldw.sql;
	cat sql/census_tiger/dw-dml.sql >> build/etldw.sql;
	cat sql/census_hhp/dw-dml.sql >> build/etldw.sql;
	cat sql/census_demographics/dw-dml.sql >> build/etldw.sql;
	cat sql/jhu_covid19/dw-dml.sql >> build/etldw.sql;
	mysql -u root -p -D covid < build/etldw.sql;
	rm -rf build;