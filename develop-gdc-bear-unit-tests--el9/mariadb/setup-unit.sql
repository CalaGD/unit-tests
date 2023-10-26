CREATE DATABASE IF NOT EXISTS testdb_my01;
GRANT ALL ON testdb_my01.* TO "test"@"localhost" IDENTIFIED BY "testpass";
GRANT ALL ON testdb_my01.* TO "test"@"%" IDENTIFIED BY "testpass";

CREATE DATABASE IF NOT EXISTS testdb_my02;
GRANT ALL ON testdb_my02.* TO "test"@"localhost" IDENTIFIED BY "testpass";
GRANT ALL ON testdb_my02.* TO "test"@"%" IDENTIFIED BY "testpass";

CREATE DATABASE IF NOT EXISTS testdb_my03;
GRANT ALL ON testdb_my03.* TO "test"@"localhost" IDENTIFIED BY "testpass";
GRANT ALL ON testdb_my03.* TO "test"@"%" IDENTIFIED BY "testpass";

CREATE DATABASE IF NOT EXISTS testdb_my04;
GRANT ALL ON testdb_my04.* TO "test"@"localhost" IDENTIFIED BY "testpass";
GRANT ALL ON testdb_my04.* TO "test"@"%" IDENTIFIED BY "testpass";

GRANT ALL ON *.* TO "test"@"localhost" IDENTIFIED BY "testpass";
GRANT ALL ON *.* TO "test"@"%" IDENTIFIED BY "testpass";

FLUSH PRIVILEGES;
