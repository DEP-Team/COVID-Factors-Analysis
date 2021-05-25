-- Must be run by priviledged root user
-- GRANT ALL PRIVILEGES not supported in Cloud SQL: https://cloud.google.com/sql/faq#:~:text=Cloud%20SQL%20does%20not%20support,use%20GRANT%20ALL%20ON%20%60%25%60.


CREATE USER 'covid_user'@'%' IDENTIFIED BY 'password';

CREATE DATABASE covid;
CREATE DATABASE covid_dw;

GRANT ALL ON covid.* TO 'covid_user'@'%';
GRANT ALL ON covid_dw.* TO 'covid_user'@'%';
