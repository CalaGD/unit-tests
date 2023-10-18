#!/usr/bin/bash

set -euo pipefail

TESTDIR_UNIT="/opt/quality/test/unit/$1"

TESTDIRS=( "$TESTDIR_UNIT" )
PROVE_INC=(
  -I/opt/common/blib
  -I/opt/common/lib
  -I/opt/common/t
  "-I$TESTDIR_UNIT"
)

env GDC_NO_INTEGRATION_TESTS=1 VERTICAINI=1 \
  prove "${PROVE_INC[@]}" -r "${TESTDIRS[@]}"
