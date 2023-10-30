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
  if podman pod exists test-gdc-perl-md; then
    podman pod stop test-gdc-perl-md
    podman pod rm test-gdc-perl-md
  fi
}

# Build and create the test containers and volumes
build_and_create() {
  podman build -t mariadb mariadb
  cp -r ../md-stat-export  ../md-stat-launcher  ../md-stat-sender .
  podman build -t tests .
  rm -rf ./md-stat*

  podman pod create test-gdc-perl-md
  podman run --pod test-gdc-perl-md -d --name mariadb mariadb
}

# Run the tests
run_tests() {
  if [ "$ATTACH" -eq 1 ];
  then
    # Attach to the container after running
    podman run -it --pod test-gdc-perl-md --entrypoint /usr/bin/bash tests
  else
	if [ ! -z "$TEST_PATH" ];
	then
      		# Run a single test file
      		podman run -it --pod test-gdc-perl-md tests $TEST_PATH
     	else
		# Run all tests
		podman run -it --pod test-gdc-perl-md tests
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
