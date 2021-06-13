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

clean:
	rm -rf build;
	mkdir -p build;


createdb: clean
	# cleanup build directory
	rm -rf build;
	mkdir -p build;

	# load all DDLs into one SQL file, in order of foreign constraint dependencies
	cat\
		sql/date/staging-ddl.sql\
		sql/census_tiger/staging-ddl.sql\
		sql/census_hhp/staging-ddl.sql\
		sql/census_demographics/staging-ddl.sql\
		sql/jhu_covid19/staging-ddl.sql\
		sql/acled_ccc_events/staging-ddl.sql\
		> build/makedb.sql;

	# run SQL file
	mysql\
		--host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		-D covid\
		< build/makedb.sql;

	# cleanup
	#rm -rf build;

importdb:
	# create date table first
	mysql\
		--host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		-D covid\
		< sql/date/staging-dml.sql;

	# import all CSVs - in order of foreign constraint dependencies
	mysqlimport\
		--host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		--local\
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
		data/import/county_cases.csv\
		data/import/actor_type.csv\
		data/import/event_type.csv\
		data/import/interaction.csv\
		data/import/actor.csv\
		data/import/acled_event.csv\
		data/import/event_actor.csv\
		data/import/issue.csv\
		data/import/protest_type.csv\
		data/import/ccc_actor.csv\
		data/import/ccc_event.csv\
		data/import/ccc_event_actor.csv\
		data/import/ccc_event_issue.csv\
		data/import/ccc_event_protest_type.csv;

importcloudsql:
	# cleanup build directory
	rm -rf build;
	mkdir -p build;

	# load all DMLs into one SQL File, in order of foreign constraint dependencies
	cat\
		sql/date/staging-dml.sql\
		sql/census_tiger/staging-dml.sql\
		sql/census_hhp/staging-dml.sql\
		sql/census_demographics/staging-dml.sql\
		sql/jhu_covid19/staging-dml.sql\
		sql/acled_ccc_events/staging-dml.sql\
		> build/importcloud.sql;

	mysql\
		--host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		-D covid\
		< build/importcloud.sql;

	# cleanup
	rm -rf build;

createdw: clean
	# clean up build directory
	rm -rf build;
	mkdir -p build;

	# load all DDLs into one SQL file, in order of foreign constraint dependencies
	cat\
		sql/date/dw-ddl.sql\
		sql/census_tiger/dw-ddl.sql\
		sql/census_hhp/dw-ddl.sql\
		sql/census_demographics/dw-ddl.sql\
		sql/jhu_covid19/dw-ddl.sql\
		sql/acled_ccc_events/dw-ddl.sql\
		> build/makedw.sql;

	# run SQL file
	mysql\
		--host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		-D covid_dw\
		 < build/makedw.sql;

 	# cleanup
	rm -rf build;

loaddw: clean
	# cleanup build directory
	rm -rf build;
	mkdir -p build;

	# load all DMLs into one SQL File, in order of foreign constraint dependencies
	cat\
		sql/date/dw-dml.sql\
		sql/census_tiger/dw-dml.sql\
		sql/census_hhp/dw-dml.sql\
		sql/census_demographics/dw-dml.sql\
		sql/jhu_covid19/dw-dml.sql\
		sql/acled_ccc_events/dw-dml.sql\
		> build/etldw.sql;

	# run SQL file
	mysql\
		--host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		-D covid\
		 < build/etldw.sql;

	# cleanup
	rm -rf build;
