#! /bin/bash

# This script is used to reset the database to a clean state.
psql -p 6061 -U jileihao -c "DROP DATABASE IF EXISTS \"avrpdb\";"
psql -p 6061 -U jileihao -c "CREATE DATABASE \"avrpdb\";"

# Apply the schema to the database
psql -p 6061 -U jileihao -d avrpdb -f sql/schemas.sql

# Apply seed data to the database
psql -p 6061 -U jileihao -d avrpdb -f sql/seed.sql

# Apply functions in the function folder
for f in sql/functions/*.sql; do
  psql -p 6061 -U jileihao -d avrpdb -f $f
done

# Apply create user
psql -p 6061 -U jileihao -d avrpdb -f sql/create_user.sql