CREATE USER test ENCRYPTED PASSWORD 'testpass';
GRANT CREATE ON DATABASE verticadb TO test;

CREATE SCHEMA testdb_vertica01;
GRANT ALL ON SCHEMA testdb_vertica01 TO test;
CREATE SCHEMA testdb_vertica02;
GRANT ALL ON SCHEMA testdb_vertica02 TO test;
CREATE SCHEMA testdb_vertica03;
GRANT ALL ON SCHEMA testdb_vertica03 TO test;
CREATE SCHEMA testdb_vertica04;
GRANT ALL ON SCHEMA testdb_vertica04 TO test;

CREATE RESOURCE POOL gdc_common_min_test;
GRANT USAGE ON RESOURCE POOL gdc_common_min_test to test;
CREATE RESOURCE POOL data_upload_pool;
GRANT USAGE ON RESOURCE POOL data_upload_pool to test;
CREATE RESOURCE POOL starjoin_interactive_fast_pool;
GRANT USAGE ON RESOURCE POOL starjoin_interactive_fast_pool to test;
CREATE RESOURCE POOL starjoin_interactive_slow_pool;
GRANT USAGE ON RESOURCE POOL starjoin_interactive_slow_pool to test;
CREATE RESOURCE POOL pixtab_fetch_pool;
GRANT USAGE ON RESOURCE POOL pixtab_fetch_pool to test;
CREATE RESOURCE POOL raw_export_pool;
GRANT USAGE ON RESOURCE POOL raw_export_pool to test;

\i /opt/vertica/udx/GdcCsvParserReinstall.sql
GRANT ALL ON PARSER public.GdcCsvParser() TO test;
