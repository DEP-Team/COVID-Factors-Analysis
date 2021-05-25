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
	touch build/makedb.sql;

	# load all DDLs into one SQL file, in order of foreign constraint dependencies
	cat sql/date/staging-ddl.sql >> build/makedb.sql;
	cat sql/census_tiger/staging-ddl.sql >> build/makedb.sql;
	cat sql/census_hhp/staging-ddl.sql >> build/makedb.sql;
	cat sql/census_demographics/staging-ddl.sql >> build/makedb.sql;
	cat sql/jhu_covid19/staging-ddl.sql >> build/makedb.sql;

	# run SQL file
	mysql\
		--host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		-D covid\
		< build/makedb.sql;

	# cleanup
	rm -rf build;

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
		data/import/county_cases.csv;

importcloudsql:
	# cleanup build directory
	rm -rf build;
	mkdir -p build;
	touch build/importcloud.sql;

	# load all DMLs into one SQL File, in order of foreign constraint dependencies
	cat sql/date/staging-dml.sql >> build/importcloud.sql;
	cat sql/census_tiger/staging-dml.sql >> build/importcloud.sql;
	cat sql/census_hhp/staging-dml.sql >> build/importcloud.sql;
	cat sql/census_demographics/staging-dml.sql >> build/importcloud.sql;
	cat sql/jhu_covid19/staging-dml.sql >> build/importcloud.sql;

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
	touch build/makedw.sql;

	# load all DDLs into one SQL file, in order of foreign constraint dependencies
	cat sql/date/dw-ddl.sql >> build/makedw.sql;
	cat sql/census_tiger/dw-ddl.sql >> build/makedw.sql;
	cat sql/census_hhp/dw-ddl.sql >> build/makedw.sql;
	cat sql/census_demographics/dw-ddl.sql >> build/makedw.sql;
	cat sql/jhu_covid19/dw-ddl.sql >> build/makedw.sql;

	# run SQL file
	mysql --host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		-D covid\
		 < build/makedw.sql;

 	# cleanup
	rm -rf build;

loaddw: clean
	# cleanup build directory
	rm -rf build;
	mkdir -p build;
	touch build/etldw.sql;

	# load all DMLs into one SQL File, in order of foreign constraint dependencies
	cat sql/date/dw-dml.sql >> build/etldw.sql;
	cat sql/census_tiger/dw-dml.sql >> build/etldw.sql;
	cat sql/census_hhp/dw-dml.sql >> build/etldw.sql;
	cat sql/census_demographics/dw-dml.sql >> build/etldw.sql;
	cat sql/jhu_covid19/dw-dml.sql >> build/etldw.sql;

	# run SQL file
	mysql --host="${MYSQL_HOST}"\
		--user="${MYSQL_USER}"\
		--password="${MYSQL_PASSWORD}"\
		-D covid\
		 < build/etldw.sql;

	# cleanup
	rm -rf build;