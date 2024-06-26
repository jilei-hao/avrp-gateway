#! /bin/bash

port=$1

# Apply functions in the function folder
for f in sql/functions/*.sql; do
  psql -p $port -U jileihao -d avrpdb -f $f
done

