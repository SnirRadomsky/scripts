const MongoClient = require('mongodb').MongoClient;

const dbName = process.env.DB_NAME || 'test'; // Default to 'test' if no DB name is provided
const uri = `mongodb://localhost:27017/${dbName}`;
const client = new MongoClient(uri);

async function migrateAuthenticationNodes() {
  try {
    await client.connect();
    console.log("Connected to MongoDB.");
    const db = client.db();

    // Function to traverse and update the object
    function traverseAndUpdate(object) {
      for (const key in object) {
        if (typeof object[key] === 'object' && object[key] !== null) {
          traverseAndUpdate(object[key]);
        } else {
          // Check for the specific type and update accordingly
          if (object.type === 'transmit_platform_authentication') {
            if (object.web_authn_enabled !== undefined) {
              object.passkeys_enabled = object.web_authn_enabled;
              delete object.web_authn_enabled;
            }
            if (object.username !== undefined) {
              object.passkeys_user_id = object.username;
              delete object.username;
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

    console.log("Authentication node migration completed.");
  } catch (error) {
    console.error('Error during authentication node migration:', error);
  } finally {
    await client.close();
  }
}

migrateAuthenticationNodes();