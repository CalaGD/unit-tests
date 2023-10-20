#!/usr/bin/sh

set -eu

stop_and_clean() {
  if podman pod exists test-gdc-bear; then
    podman pod stop test-gdc-bear
    podman pod rm test-gdc-bear
  fi
  if podman volume exists pg-tests-sv; then
	  podman volume rm pg-tests-sv
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
podman run --pod test-gdc-bear -d --name vertica vertica
podman run --pod test-gdc-bear -d --name rabbitmq rabbitmq
echo sleeping…; sleep 30
#podman run -it --pod test-gdc-bear --entrypoint /usr/bin/bash -v pg-tests-sv:/tmp/mddwh_pg_export_test tests
#podman run --pod test-gdc-bear -d --name tests --entrypoint /usr/bin/bash tests
podman run -it --pod test-gdc-bear -v pg-tests-sv:/tmp/mddwh_pg_export_test tests

#stop_and_clean
