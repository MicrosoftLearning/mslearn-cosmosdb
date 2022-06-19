---
lab:
    title: 'Create MongoDB app using ***Node.js*** Azure Cosmos DB API for MongoDB'
    module: 'Module 1 - Get Started with Azure Cosmos DB API for MongoDB '
---

# Create MongoDB app using ***Node.js*** Azure Cosmos DB API for MongoDB

In this exercise, you'll create an Azure Cosmos DB API for MongoDB account, a database, a collection and add a couple of items to the collection. You'll notice that this code will be identical to how you would connect to any MongoDB database.  You'll then create a collection using extension commands that allow you to define the throughput in Request Units/sec (RUs) for the collection.

## Prepare your development environment

If you haven't already prepared the Azure Cosmos DB database where you're working on this lab, follow these steps to do so. Otherwise, go to the **Create Collection and items** section.

1. In Azure Cloud Shell, copy and paste the following commands.

    ```bash
    # Update Azure Cloud Shell node to Version 14.0.0, since the MongoDB driver requires ver 10+
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.nvm/nvm.sh
    nvm install 14.0.0
    npm install -g mongodb
    npm link mongodb
    
    # Create an Azure Cosmos DB API for MongoDB account
    git clone https://github.com/MicrosoftLearning/mslearn-cosmosdb.git
    cd mslearn-cosmosdb/api-for-mongodb/01-create-mongodb-objects/
    bash init.sh
    ```

    > &#128221; Note that this bash script will create the Azure Cosmos DB API for MongoDB account. *It can take 5-10 minutes to create this account* so it might be a good time to get a cup of coffee or tea. 

   > &#128161; If you come back and your cloud shell has reset, run the following commands in the cloud shell to use Node version 14, otherwise the code in the next section will fail.

    >1. source ~/.nvm/nvm.sh
    >1. nvm install 14.0.0
    >1. npm link mongodb

1. When the bash *init.sh* file completes running, copy somewhere the ***Connection String*** returned, we'll need it in the next section. You can also review the JSON  returned by the account creation script that is located before the connection string.

    1. Note the name of the account will be something like **learn-account-cosmos-########-location**.  

    1. If you look somewhere in the middle of the JSON, you should see the property **"kind": "MongoDB"**.

## Add the code to create the databases, collection and item to the App.js file

It's now time to add our JavaScript code to create a Database, a Collection and add an item to the collection.

1. In not already opened, open the Azure Cloud Shell.

1. Run the following command to open the code editor.

    ```bash
    cd ./node/
    code App.js
    ```

1. Copy the following code to the App.js file. *Don't forget that you'll need to replace the url value for the connection string copied in step 2 of the previous section*. This connection string should look like

    mongodb://learn-account-cosmos-92903170:XvrarRd8LnqWNZiq3ahHXngbZoVRxVO192WahrcdsmHVivBGbRqnHx2cq0oMGnc0DUPAWpyGu7kt7APVH4nqXg==@learn-account-cosmos-92903170.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@learn-account-cosmos-92903170@.  

    This part of the code uses the MongoDB drivers and uses the connection string to Azure Cosmos DB like you would normally use a connection string to any MongoDB server.  The code then defines and opens the connection to the Azure Cosmos DB account.

    ```JavaScript
    // Uses the MongoDB driver
    const {MongoClient} = require("mongodb");
    
    async function main() {
    
      // Replace below "YourAzureCosmosDBAccount" with the name of your Azure Cosmos DB 
      // account name and "YourAzureCosmosDBAccountKEY" with the Azure Cosmos DB account key.
      // Or replace is with the connection string if you have it.
      var url = "mongodb://YourAzureCosmosDBAccount:YourAzureCosmosDBAccountKEY@YourAzureCosmosDBAccount.mongo.cosmos.azure.com:10255/?ssl=true&retrywrites=false&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@YourAzureCosmosDBAccount@";
    
      // define the connection using the MongoClient method ane the url above
      var mongoClient = new MongoClient(url, function(err,client)
        {
          if (err)
          {
            console.log("error connecting")
          }
        }
      );
    
      // open the connection
      await mongoClient.connect();
        
    ```

1. The next step connects to the **products** database. Note that if this database doesn't exist it will create it only if also creates a collection in the same connection. Add the following script to the editor.

    ```javascript
      // connect to the database "products"
      var ProductDatabase = mongoClient.db("products");
    
    ```

1. Next, we'll connect to the **documents** collection if it already exists, and then adds one item to the collection. Note that if the collection doesn't exist this code will only create the collection if it also performs an operation on that collection in the same connection (for example, like add an item to the collection). Add the following script to the editor.

    ```javascript
      // create a collection "documents" and add one item for "bread"
      var collection = ProductDatabase.collection('documents');
      var insertResult = await collection.insertOne({ ProductId: 1, name: "bread" });
    
    ```

1. Lets now search for the item we just inserted and display it to the shell. Add the following script to the editor.

    ```javascript
      // return data where ProductId = 1
      const findProduct = await collection.find({ProductId: 1});
      await findProduct.forEach(console.log);
    
    ```

1. Finally let's close the connection and call the *main* function to run it. Add the following script to the editor.

    ```javascript
      // close the connection
      mongoClient.close();
    }
    
    main();
    ```

1. The script should look like this:

    ```JavaScript
    // Uses the MongoDB driver
    const {MongoClient} = require("mongodb");
    
    async function main() {
    
      // Replace below "YourAzureCosmosDBAccount" with the name of your Azure Cosmos DB 
      // account name and "YourAzureCosmosDBAccountKEY" with the Azure Cosmos DB account key.
      // Or replace is with the connection string if you have it.
      var url = "mongodb://YourAzureCosmosDBAccount:YourAzureCosmosDBAccountKEY@YourAzureCosmosDBAccount.mongo.cosmos.azure.com:10255/?ssl=true&retrywrites=false&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@YourAzureCosmosDBAccount@";
    
      // define the connection using the MongoClient method ane the url above
      var mongoClient = new MongoClient(url, function(err,client)
        {
          if (err)
          {
            console.log("error connecting")
          }
        }
      );
    
      // open the connection
      await mongoClient.connect();
        
      // connect to the database "products"
      var ProductDatabase = mongoClient.db("products");
    
      // create a collection "documents" and add one item for "bread"
      var collection = ProductDatabase.collection('documents');
      var insertResult = await collection.insertOne({ ProductId: 1, name: "bread" });
    
      // return data where ProductId = 1
      const findProduct = await collection.find({ProductId: 1});
      await findProduct.forEach(console.log);
    
      // close the connection
      mongoClient.close();
    }
    
    main();
    ```

1. Let's go ahead and save the JavaScript program.  Select on the Upper right hand corner of the code editor and select **Save**. Now select **Close Editor** to go back to the Shell.

1. Let's now run the JavaScript App with the following command.

    ```bash
    node App.js
    ```  

1. This should return a similar result to the one below.  This means that we created the database, collection and added an item to it.

    ```json
    {
      _id: new ObjectId("62aed08663c0fd62d30240db"),
      ProductId: 1,
      name: 'bread'
    }
    ```

As you should have noticed, this code is the same code you would run to create a database, collection and item on a MongoDB database. So programming for Azure Cosmos DB API for MongoDB should be transparent to you if you're already familiar with creating apps that connect to MongoDB.
