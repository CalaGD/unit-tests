#!/usr/bin/sh

set -eu

POSITIONAL_ARGS=()
ATTACH="0"
TEST_PATH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -a|-A)
      ATTACH="1"
      shift
      ;;
    -st|--single-test)
      TEST_PATH="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

stop_and_clean() {
  if podman pod exists test-gdc-bear; then
    podman pod stop test-gdc-bear
    podman pod rm test-gdc-bear
  fi
  if podman volume exists pg-tests-sv; then
	  podman volume rm pg-tests-sv
  fi
  if podman volume exists vt-tests-sv; then
	  podman volume rm vt-tests-sv
  fi
}

stop_and_clean

podman volume create pg-tests-sv

podman build -t mariadb mariadb
podman build -t postgres postgres
podman build -t vertica vertica
podman build -t rabbitmq rabbitmq
podman build -t tests .

podman pod create test-gdc-bear
podman run --pod test-gdc-bear -d --name postgres -v pg-tests-sv:/tmp/mddwh_pg_export_test postgres
podman run --pod test-gdc-bear -d --name mariadb mariadb
podman run --pod test-gdc-bear -d --name vertica -v vt-tests-sv:/tmp/mddwh_vertica_export_temp vertica
podman run --pod test-gdc-bear -d --name rabbitmq rabbitmq

echo sleeping…; sleep 30

if [ "$ATTACH" -eq 1 ];
then
	podman run -it --pod test-gdc-bear --entrypoint /usr/bin/bash -v pg-tests-sv:/tmp/mddwh_pg_export_test -v vt-tests-sv:/tmp/mddwh_vertica_export_temp tests
	exit 1;
else if [ ! -z "$TEST_PATH" ];
	then
		podman run -it --pod test-gdc-bear -v pg-tests-sv:/tmp/mddwh_pg_export_test -v vt-tests-sv:/tmp/mddwh_vertica_export_temp tests $TEST_PATH
		exit 1;
	fi
        podman run -it --pod test-gdc-bear -v pg-tests-sv:/tmp/mddwh_pg_export_test -v vt-tests-sv:/tmp/mddwh_vertica_export_temp tests
fi
