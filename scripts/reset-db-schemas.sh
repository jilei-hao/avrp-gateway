#! /bin/bash

# This script is used to reset the database to a clean state.
psql -p 6061 -U jileihao -c "DROP DATABASE IF EXISTS \"avrpdb\";"
psql -p 6061 -U jileihao -c "CREATE DATABASE \"avrpdb\";"

# Apply the schema to the database
psql -p 6061 -U jileihao -d avrpdb -f sql/schemas.sql

# Apply seed data to the database
psql -p 6061 -U jileihao -d avrpdb -f sql/seed.sql