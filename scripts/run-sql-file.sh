#! /bin/bash
port=$1

psql -p $port -U jileihao -d avrpdb -f $2