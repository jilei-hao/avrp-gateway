#! /bin/bash

# Apply functions in the function folder

psql -p 6061 -U jileihao -d avrpdb -f sql/reset-study-status.sql


