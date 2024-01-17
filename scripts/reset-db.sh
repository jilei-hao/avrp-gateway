#! /bin/bash

# reset schemas and reapply seed data
./scripts/reset-db-schemas.sh

# reset functions
./scripts/reset-db-functions.sh

# Apply create user
psql -p 6061 -U jileihao -d avrpdb -f sql/create_user.sql