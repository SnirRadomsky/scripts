#!/bin/bash

# MongoDB connection details
DB_NAME="test"
COLLECTION_NAME="applications"
MONGO_URI="mongodb://localhost:27017/"

# Check if default_application exists
mongo $MONGO_URI --quiet --eval "
  db = db.getSiblingDB('$DB_NAME');
  var defaultApp = db.$COLLECTION_NAME.findOne({ _id: '6540a0168d59c22927629802' });
  print('Default Application:', JSON.stringify(defaultApp));
" > default_app_check.json

DEFAULT_APP_EXISTS=$(cat default_app_check.json | grep -o 'null')

If default application does not exist, insert a default one
if [ "$DEFAULT_APP_EXISTS" == "null" ]; then
  echo "Default application not found. Inserting a default application."
  mongo $MONGO_URI --quiet --eval "
    db = db.getSiblingDB('$DB_NAME');
    db.$COLLECTION_NAME.insertOne({
      _id: 'default_application',
      policies: [],
      procedures: []
    });
    print('Default application inserted.');
  "
fi

# Aggregate policies and procedures from all applications except the default one and update the default application
mongo $MONGO_URI --quiet --eval "
  db = db.getSiblingDB('$DB_NAME');
  
  // Aggregate policies and procedures
  var aggregatedData = db.$COLLECTION_NAME.aggregate([
    { \$match: { _id: { \$ne: 'default_application' } } },
    {
      \$group: {
        _id: null,
        allPolicies: { \$push: '\$policies' },
        allProcedures: { \$push: '\$procedures' }
      }
    }
  ]).toArray();
  
  print('Aggregated Data:', JSON.stringify(aggregatedData));
  
  if (aggregatedData.length > 0) {
    var allPolicies = [].concat.apply([], aggregatedData[0].allPolicies);
    var allProcedures = [].concat.apply([], aggregatedData[0].allProcedures);
    
    // Print policies and procedures for debugging
    print('All Policies:', JSON.stringify(allPolicies));
    print('All Procedures:', JSON.stringify(allProcedures));

    // Find the default application
    var defaultApp = db.$COLLECTION_NAME.findOne({ _id: 'default_application' });
    print('Default Application:', JSON.stringify(defaultApp));
    
    if (defaultApp) {
      defaultApp.policies = (defaultApp.policies || []).concat(allPolicies);
      defaultApp.procedures = (defaultApp.procedures || []).concat(allProcedures);
      db.$COLLECTION_NAME.updateOne(
        { _id: 'default_application' },
        { \$set: { policies: defaultApp.policies, procedures: defaultApp.procedures } }
      );
      print('Default application updated successfully.');
    } else {
      print('Default application not found.');
    }
  } else {
    print('No data to aggregate.');
  }
"