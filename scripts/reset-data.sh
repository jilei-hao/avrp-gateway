#! /bin/bash

port=$1

psql -p $port -U jileihao -d avrpdb -f sql/reset-data.sql