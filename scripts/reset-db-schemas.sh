#! /bin/bash

port=$1

# This script is used to reset the database to a clean state.
psql -p $port -U jileihao -c "DROP DATABASE IF EXISTS \"avrpdb\";"
psql -p $port -U jileihao -c "CREATE DATABASE \"avrpdb\";"

# Apply the schema to the database
psql -p $port -U jileihao -d avrpdb -f sql/schemas.sql

# Apply seed data to the database
psql -p $port -U jileihao -d avrpdb -f sql/seed.sql