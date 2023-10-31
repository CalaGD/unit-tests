#!/usr/bin/bash

set -euo pipefail

if [ ! $# -eq 0 ];
then
	IT="-v $1"
	TESTDIRS=($IT)
else
	TESTDIRS=(       
		/opt/quality/test/unit/gdc-metadata-apps
	)
fi

PROVE_INC=(
	-I/opt/common/blib
	-I/opt/common/lib
	-I/opt/common/t
	-I/opt/quality/test/unit/gdc-metadata-apps
)

env GDC_NO_INTEGRATION_TESTS=1 VERTICAINI=1 \
  prove "${PROVE_INC[@]}" -r "${TESTDIRS[@]}"
