#!/usr/bin/sh

# Set the shell to exit immediately if a command exits with a non-zero status
# and to exit when an undefined variable is referenced.
set -eu

# Parse command line arguments
parse_args() {
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
        shift
        shift
        ;;
      -h|--help)
        # Display usage information and exit
        echo "Usage: ./script.sh [-a] [-st <test_path>] [-h]"
        echo "Options:"
        echo "  -a, -A              Attach to the container after running"
        echo "  -st, --single-test  Run a single test file"
        echo "  -h, --help          Show this help message and exit"
        exit 0
        ;;
      -*|--*)
        # Display an error message and exit if an unknown option is provided
        echo "Unknown option $1"
        exit 1
        ;;
      *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
  done
}

# Stop and remove the test containers and volumes
stop_and_clean() {
  if podman pod exists perl-gdc-taskmanager; then
    podman pod stop perl-gdc-taskmanager
    podman pod rm perl-gdc-taskmanager
  fi
  if podman volume exists vt-tests-sv; then
    podman volume rm vt-tests-sv
  fi
}

# Build and create the test containers and volumes
build_and_create() {
  podman volume create vt-tests-sv

  podman build -t vertica vertica
  podman build -t tests .

  podman pod create perl-gdc-taskmanager
  podman run --pod perl-gdc-taskmanager -d --name vertica -v vt-tests-sv:/tmp/mddwh_vertica_export_temp vertica
}

# Run the tests
run_tests() {
  if [ "$ATTACH" -eq 1 ];
  then
    # Attach to the container after running
    podman run -it --pod perl-gdc-taskmanager --entrypoint /usr/bin/bash -v vt-tests-sv:/tmp/mddwh_vertica_export_temp tests
  else
	if [ ! -z "$TEST_PATH" ];
    	then
      		# Run a single test file
      		podman run -it --pod perl-gdc-taskmanager -v vt-tests-sv:/tmp/mddwh_vertica_export_temp tests $TEST_PATH
     	else
    		# Run all tests
    		podman run -it --pod perl-gdc-taskmanager -v vt-tests-sv:/tmp/mddwh_vertica_export_temp tests
  	fi
  fi
}

# Call the functions to parse arguments, stop and clean, build and create, and run tests
parse_args "$@"
stop_and_clean
build_and_create
echo sleeping…; sleep 30
run_tests
exit 0
