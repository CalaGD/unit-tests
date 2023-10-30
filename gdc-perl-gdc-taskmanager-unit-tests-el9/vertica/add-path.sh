#!/bin/bash

VERTICA_NODE=$( /opt/vertica/bin/vsql -U vertica -A -t -c "select node_name from nodes" )
SQL="SELECT ADD_LOCATION( '/tmp/mddwh_vertica_export_temp', '$VERTICA_NODE', 'USER' );"
vsql -U vertica -c "$SQL"
