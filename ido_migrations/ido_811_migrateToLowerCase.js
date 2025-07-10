console.log("Starting key and value rename operation...");
// MongoDB connection
const MongoClient = require('mongodb').MongoClient;

const dbName = process.env.DB_NAME || 'test'; // Use the environment variable or 'test' as the default

// Modify the URI based on the database name
const uri = `mongodb://localhost:27017/${dbName}`;
const client = new MongoClient(uri);

async function renameKeysAndValues() {
  try {
    await client.connect();
    console.log("Connected to MongoDB.");

    const db = client.db();

    function renameKeysAndValues(obj) {
      for (let key in obj) {
        if (typeof obj[key] === 'object' && obj[key] !== null) {
          renameKeysAndValues(obj[key]);
        }

        if (key === 'webAuthn_enabled') {
          obj['web_authn_enabled'] = obj[key];
          delete obj[key];
        }

        if (key === 'allow_cross_Platform_authenticators') {
          obj['allow_cross_platform_authenticators'] = obj[key];
          delete obj[key];
        }

        if (obj[key] === 'transmit_platform_webAuthn_registration') {
          obj[key] = 'transmit_platform_web_authn_registration';
        }
      }
    }

    const documents = await db.collection("applications").find({}).toArray();

    for (const doc of documents) {
      try {
        renameKeysAndValues(doc);
        const updateResult = await db.collection("applications").updateOne({ _id: doc._id }, { $set: doc });
        if (updateResult.modifiedCount === 0) {
          console.warn('No documents were updated for _id:', doc._id);
        }
      } catch (error) {
        console.error('Error updating document:', error);
      }
    }

    console.log("Key and value rename operation completed.");
  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
  } finally {
    client.close();
  }
}

renameKeysAndValues();