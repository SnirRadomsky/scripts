const MongoClient = require('mongodb').MongoClient;

// Replace 'dbName' with your database name
const dbName = process.env.DB_NAME || 'test';
const uri = `mongodb://localhost:27017/${dbName}`;
const client = new MongoClient(uri);

async function migrateEscapeFailureIdAndPresentation() {
  try {
    await client.connect();
    console.log("Connected to MongoDB.");
    const db = client.db();

    // Recursive function to traverse and update the object
    function traverseAndUpdate(object) {
      for (const key in object) {
        if (typeof object[key] === 'object') {
          traverseAndUpdate(object[key]);
        } else {
          if (key === 'id' && object[key] === 'action_failure') {
            object[key] = 'failure';
          }
          if (key === 'presentation') {
            if (object[key] === 'action_failure' || object[key] === 'failure') {
              object[key] = 'Failure';
            } else if (object[key] === 'cancel') {
              object[key] = 'Cancel';
            }
          }
        }
      }
    }

    // Fetch all documents from your collection
    const collection = db.collection('applications');
    const documents = await collection.find({}).toArray();

    // Traverse each document and update it
    for (const doc of documents) {
      traverseAndUpdate(doc);
      await collection.updateOne({ _id: doc._id }, { $set: doc });
    }

    console.log("Migration of escape failure IDs and presentations completed.");
  } catch (error) {
    console.error('Error during migration:', error);
  } finally {
    client.close();
  }
}

migrateEscapeFailureIdAndPresentation();