#! /bin/bash

# Apply functions in the function folder
for f in sql/functions/*.sql; do
  psql -p 6061 -U jileihao -d avrpdb -f $f
done

