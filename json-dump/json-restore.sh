#!/bin/bash

# MongoDB host and database name
if [ -z $DB_NAME ]; then
    echo "Defaulting to DB: test-base"
    DB_NAME="test-base"
fi
if [ -z $MONGO_PORT ]; then
    MONGO_PORT=27017
fi
if [ -z $MONGO_HOST ]; then
    MONGO_HOST=mongo_host
fi

# Input file name
input_file=$1

# Loop over each field in the merged JSON file
for field in $(jq 'keys[]' $input_file); do
    # Collection name is the same as the field name
    collection_name=$field
    # Extract JSON array from field
    json_array=$(jq ".$field" $input_file)
    # Run mongoimport command
    echo "Importing $collection_name collection"
    echo $json_array | mongoimport --host $MONGO_HOST --port $MONGO_PORT --db $DB_NAME --collection $collection_name --jsonArray
done