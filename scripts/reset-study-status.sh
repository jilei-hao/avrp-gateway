#! /bin/bash

# Apply functions in the function folder
port=$1

psql -p $port -U jileihao -d avrpdb -f sql/reset-study-status.sql


