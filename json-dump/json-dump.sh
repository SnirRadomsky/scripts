#!/bin/bash

curtime=$(date +%s)
dir=temp_$curtime
mkdir $dir

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


# Database name
collections=$(mongo $DB_NAME --host $MONGO_HOST --port $MONGO_PORT --eval "db.getCollectionNames().forEach(function(collection){if(db[collection].count() > 0){print(collection)}})" --quiet)

# Loop through all collections in the database
for collection_name in $collections; do

# Export collection to JSON file
if [ $collection_name != ']' ] && [ $collection_name != '[' ]; then
    mongoexport --db $DB_NAME --host $MONGO_HOST --port $MONGO_PORT --collection $collection_name --out ./$dir/$collection_name.json --jsonArray --pretty
fi

done


# Output file name
output_file="$DB_NAME-$curtime.json"
    
# Merge all JSON files into a single JSON object
echo "{" > $output_file
for file in $(ls $dir/*.json); do
    if [ -s $file ]; then
        # Extract object name from file name
        object_name=$(basename -s .json $file)
        # Add object name and contents to output file
        echo "\"$object_name\": $(cat $file)," >> $output_file
    fi
done
# Remove trailing comma and close JSON object
echo $(sed '$s/,$//' $output_file) > $output_file
echo "}" >> $output_file

jq . $output_file > temp.json
mv temp.json $output_file

echo export finished to $output_file

rm -rf ./$dir