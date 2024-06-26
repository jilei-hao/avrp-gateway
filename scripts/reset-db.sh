#! /bin/bash
port=$1

# reset schemas and reapply seed data
./scripts/reset-db-schemas.sh $port

# reset functions
./scripts/reset-db-functions.sh $port

# Apply create user
psql -p 6061 -U jileihao -d avrpdb -f sql/create_user.sql