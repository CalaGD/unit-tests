#!/usr/bin/sh

set -eu

stop_and_clean() {
  if podman pod exists test-gdc-bear; then
    podman pod stop test-gdc-bear
    podman pod rm test-gdc-bear
  fi
}

stop_and_clean

podman build -t mariadb mariadb
podman build -t postgres postgres
podman build -t vertica vertica
podman build -t tests .

podman pod create test-gdc-bear
podman run --pod test-gdc-bear -d --name postgres postgres
podman run --pod test-gdc-bear -d --name mariadb mariadb
podman run --pod test-gdc-bear -d --name vertica vertica
#echo sleeping…; sleep 30
podman run -it --pod test-gdc-bear --entrypoint /usr/bin/bash tests
#podman run --pod test-gdc-bear -d --name tests --entrypoint /usr/bin/bash tests
#podman run -it --pod test-gdc-bear tests

#stop_and_clean
