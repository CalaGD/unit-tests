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
  if podman pod exists gdc-metadata-apps; then
    podman pod stop gdc-metadata-apps
    podman pod rm gdc-metadata-apps
  fi
}

# Build and create the test containers and volumes
build_and_create() {

  podman build -t mariadb mariadb
  podman build -t tests .

  podman pod create gdc-metadata-apps
  podman run --pod gdc-metadata-apps -d --name mariadb mariadb
}

# This works only under assumption that this whole ordeal is present in test folder under correct repository
copy_test_list() {
	#Add test files here manually if needed.
	TEST_LIST=(
		../project-model/t/GDC/TaskManager/Workers/
		../project-model/t/GDC/Project/Model/
	)
	#Add module files here manually if needed.
	MODULE_LIST=(
		../project-model/lib/GDC/TaskManager/Workers/
		../project-model/lib/GDC/Project/Model/
	)
				
	#mkdir ./tests

	for filepath in "${TEST_LIST[@]}"; do
		COPYTO="tests"`sed 's/.*\/t//'<<<"$filepath"`
		mkdir -p $COPYTO
		cp $filepath*.t $COPYTO
	done

	#mkdir ./modules

	for filepath in "${MODULE_LIST[@]}"; do
		COPYTO="modules"`sed 's/.*\/lib//'<<<"$filepath"`
		mkdir -p $COPYTO
		cp $filepath/*.pm $COPYTO
	done
}

rm_artefacts() {
	rm -rf tests
	rm -rf modules
}

# Run the tests
run_tests() {
  if [ "$ATTACH" -eq 1 ];
  then
    # Attach to the container after running
    podman run -it --pod gdc-metadata-apps --entrypoint /usr/bin/bash tests
  else
	if [ ! -z "$TEST_PATH" ];
	then
      		# Run a single test file
      		podman run -it --pod gdc-metadata-apps tests $TEST_PATH
     	else
		# Run all tests
		podman run -it --pod gdc-metadata-apps tests
	fi
  fi
}

# Call the functions to parse arguments, stop and clean, build and create, and run tests
parse_args "$@"
stop_and_clean
copy_test_list
build_and_create
rm_artefacts
echo sleeping…; sleep 30
run_tests
exit 0
