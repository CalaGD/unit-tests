#!/usr/bin/bash

set -euo pipefail

if [ ! $# -eq 0 ];
then
	IT="-v $1"
	TESTDIRS=($1)
else
	TESTDIRS=(       
		/opt/common/t 
	      	/opt/resources/t
	)
fi

PROVE_INC=(
	-I/opt/common/blib 
	-I/opt/common/lib
	-I/opt/common/t
	-I/opt/quality/test/unit/gdc-c3client
	-I/opt/resources/lib
	-I/opt/resources/t
	-I/opt/quality 
)

env GDC_NO_INTEGRATION_TESTS=1 VERTICAINI=1 \
  prove "${PROVE_INC[@]}" -r "${TESTDIRS[@]}"
