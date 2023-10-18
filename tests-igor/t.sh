#!/usr/bin/sh

set -eu

stop_and_clean() {
  if podman pod exists test-gdc-common-min; then
    podman pod stop test-gdc-common-min
    podman pod rm test-gdc-common-min
  fi
}

stop_and_clean

podman build -t mariadb mariadb
podman build -t postgres postgres
podman build -t vertica vertica
podman build -t tests .

podman pod create test-gdc-common-min
podman run --pod test-gdc-common-min -d --name postgres postgres
podman run --pod test-gdc-common-min -d --name mariadb mariadb
podman run --pod test-gdc-common-min -d --name vertica vertica
echo sleeping…; sleep 30
#podman run -it --pod test-gdc-common-min --entrypoint /usr/bin/bash tests
podman run -it --pod test-gdc-common-min tests gdc-common-min

#stop_and_clean
