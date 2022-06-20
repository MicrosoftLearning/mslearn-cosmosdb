---
lab:
    title: 'Create MongoDB app using ***Java*** Azure Cosmos DB API for MongoDB'
    module: 'Module 1 - Get Started with Azure Cosmos DB API for MongoDB '
---

# Create MongoDB app using ***Java*** Azure Cosmos DB API for MongoDB

In this exercise, you'll create an Azure Cosmos DB API for MongoDB account, a database, a collection and add a couple of items to the collection. You'll notice that this code will be identical to how you would connect to any MongoDB database. To use the Java engine, we'll create and compile an App running *Maven*. You'll then create a collection using extension commands that allow you to define the throughput in Request Units/sec (RUs) for the collection.

## Prepare your development environment

If you haven't already prepared the environment and the Azure Cosmos DB account where you're working on this lab, follow these steps to do so. Otherwise, go to the **Add the code to create the databases, collection and item to the App.java file** section.

1. In Azure Cloud Shell, copy and paste the following commands.

    ```bash
    git clone https://github.com/MicrosoftLearning/mslearn-cosmosdb.git
    cd mslearn-cosmosdb/api-for-mongodb/01-create-mongodb-objects/java
    # Download and install the Maven project, this will take a minute or two
    mvn archetype:generate -DgroupId=com.fabrikam -DartifactId=AzureApp -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
    # Replace the projects pom.xml file with the github one that has the MongoDB definition
    mv pom.xml1 ./AzureApp/pom.xml

    # Create an Azure Cosmos DB API for MongoDB account
    bash ../init.sh
    ```

    > &#128221; Note that this bash script will create the Azure Cosmos DB API for MongoDB account. *It can take 5-10 minutes to create this account* so it might be a good time to get a cup of coffee or tea.

1. When the bash *init.sh* file completes running, copy the ***Connection String*** returned somewhere, we'll need it in the next section. Additionally, you need to also review the JSON  returned by the account creation script that is located before the connection string.  *We'll need the ***account name*** and the ***resource group name***, copy those values somewhere.*

    1. Note the name of the account name will be something like **learn-account-cosmos-########-location**.  

    1. If you look somewhere in the middle of the JSON, you should see the property **"kind": "MongoDB"**.

## Add the code to create the databases, collection and item to the App.java file

It's now time to add our Java code to create a Database, a Collection and add an item to the collection.

1. In not already opened, open the Azure Cloud Shell.

1. Run the following command to open the code editor.

    ```bash
    cd ~/mslearn-cosmosdb/api-for-mongodb/01-create-mongodb-objects/java/AzureApp
    code ./src/main/java/com/fabrikam/App.java
    ```

1. Copy the following code and *replace the existing content* from the App.js file. *Don't forget that you'll need to replace the uri value for the connection string copied in step 2 of the previous section*. This connection string should look like

    mongodb://learn-account-cosmos-92903170:XvrarRd8LnqWNZiq3ahHXngbZoVRxVO192WahrcdsmHVivBGbRqnHx2cq0oMGnc0DUPAWpyGu7kt7APVH4nqXg==@learn-account-cosmos-92903170.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@learn-account-cosmos-92903170@.  

    This part of the code uses the MongoDB drivers and uses the connection string to Azure Cosmos DB like you would normally use a connection string to any MongoDB server.  The code then defines and opens the connection to the Azure Cosmos DB account.

    ```Java
    package com.fabrikam;

    // Uses the MongoDB driver
    import com.mongodb.MongoClient;
    import com.mongodb.MongoClientURI;
    import com.mongodb.client.MongoDatabase;
    import com.mongodb.client.MongoCollection;
    import org.bson.Document;
    import static com.mongodb.client.model.Filters.eq;

    public class App {
        public static void main(String[] args) {

            // Remember to replace below "YourAzureCosmosDBAccount" with the name of your Azure Cosmos DB 
            // account name and "YourAzureCosmosDBAccountKEY" with the Azure Cosmos DB account key.
            // Or replace is with the connection string if you have it.
            MongoClientURI uri = new MongoClientURI("mongodb://YourAzureCosmosDBAccount:YourAzureCosmosDBAccountKEY@YourAzureCosmosDBAccount.mongo.cosmos.azure.com:10255/?ssl=true&retrywrites=false&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@YourAzureCosmosDBAccount@");
    
            MongoClient mongoClient = null;
            try {
                // define the connection using the MongoClient method ane the url above and open the connection 
                mongoClient = new MongoClient(uri);
    
    ```

1. The next step connects to the **products** database. Note that if this database doesn't exist it will create it only if also creates a collection in the same connection. Add the following to the script in the editor.

    ```java
                // connect to the database "products"
                MongoDatabase ProductDatabase = mongoClient.getDatabase("products");
    
    ```

1. Next, we'll connect to the **documents** collection if it already exists, and then adds one item to the collection. Note that if the collection doesn't exist this code will only create the collection if it also performs an operation on that collection in the same connection (for example, like add an item to the collection). Add the following to the script in the editor.

    ```java
                // create a collection "documents" and add one item for "bread" 
                MongoCollection collection = ProductDatabase.getCollection("products");
    
                collection.insertOne(new Document()
                            .append("ProductId", 1)
                            .append("name", "bread"));
    
    ```

1. Lets now search for the item we just inserted and display it to the shell. Add the following to the script in the editor.

    ```java
                // return data where ProductId = 1
                Document findProduct = (Document) collection.find(eq("ProductId", 1)).first();
                System.out.println(findProduct.toJson());
            }
    ```

1. Finally let's close the connection. Add the following to the script in the editor.

    ```java
            // close the connection
            finally {
                if (mongoClient != null) {
                    mongoClient.close();
                }
            }
        }
    }
    ```

1. The script should look like this:

    ```java
    package com.fabrikam;

    // Uses the MongoDB driver
    import com.mongodb.MongoClient;
    import com.mongodb.MongoClientURI;
    import com.mongodb.client.MongoDatabase;
    import com.mongodb.client.MongoCollection;
    import org.bson.Document;
    import static com.mongodb.client.model.Filters.eq;

    public class App {
        public static void main(String[] args) {

            // Remember to replace below "YourAzureCosmosDBAccount" with the name of your Azure Cosmos DB 
            // account name and "YourAzureCosmosDBAccountKEY" with the Azure Cosmos DB account key.
            // Or replace is with the connection string if you have it.
            MongoClientURI uri = new MongoClientURI("mongodb://YourAzureCosmosDBAccount:YourAzureCosmosDBAccountKEY@YourAzureCosmosDBAccount.mongo.cosmos.azure.com:10255/?ssl=true&retrywrites=false&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@YourAzureCosmosDBAccount@");
    
            MongoClient mongoClient = null;
            try {
                // define the connection using the MongoClient method ane the url above and open the connection 
                mongoClient = new MongoClient(uri);
    
                // connect to the database "products"
                MongoDatabase ProductDatabase = mongoClient.getDatabase("products");
    
                // create a collection "documents" and add one item for "bread" 
                MongoCollection collection = ProductDatabase.getCollection("products");
    
                collection.insertOne(new Document()
                            .append("ProductId", 1)
                            .append("name", "bread"));
    
                // return data where ProductId = 1
                Document findProduct = (Document) collection.find(eq("ProductId", 1)).first();
                System.out.println(findProduct.toJson());
            }
            // close the connection
            finally {
                if (mongoClient != null) {
                    mongoClient.close();
                }
            }
        }
    }
    ```

1. Let's go ahead and save the Java program.  Select on the Upper right hand corner of the code editor and select **Save** (or Ctrl+S). Now select **Close Editor** (or Ctrl+Q) to go back to the Shell.

1. Let's now run the Java App with the following command.

    ```bash
    mvn clean compile exec:java
    ```  

1. This should return a similar result to the one below. As we mentioned at the beginning of this exercise, we're using *Maven* to build and compile this app.  You'll notice that this output is very chatty, this is normal since this output is usually piped to a log file. However towards the end, you should see this *INFO* message below with the JSON results of our **ProductId = 1** query in our code.  This means that we created the database, collection and added an item to it.

    ```json
    INFO: Opened connection [connectionId{localValue:3, serverValue:74678510}] to learn-account-cosmos-665601-westus.mongo.cosmos.azure.com:10255
    { "_id" : { "$oid" : "62afa8c3dff473012e7b7910" }, "ProductId" : 1, "name" : "bread" }
    Jun 19, 2022 10:52:59 PM com.mongodb.diagnostics.logging.JULLogger log
    INFO: Closed connection [connectionId{localValue:3, serverValue:74678510}] to learn-account-cosmos-665601-westus.mongo.cosmos.azure.com:10255 because the pool has been closed.
    ```

As you should have noticed, this code is the same code you would run to create a database, collection and item on a MongoDB database. So programming for Azure Cosmos DB API for MongoDB should be transparent to you if you're already familiar with creating apps that connect to MongoDB.

## Using extension commands to manage data stored in Azure Cosmos DB’s API for MongoDB

While the code above, except for the connection string, would be identical between connecting to a MongoDB Server then connection to our Azure Cosmos DB API for MongoDB account, this might not take advantage of Azure Cosmos DB features. What this means is using the default driver methods to create our collections, will also use the default Azure Cosmos DB Account parameters  to create those collections. So we won't be able to define creation parameters like our throughput, sharding key or autoscaling settings using those methods.

By using the Azure Cosmos DB’s API for MongoDB, you can enjoy the benefits of Cosmos DB such as global distribution, automatic sharding, high availability, latency guarantees, automatic, encryption at rest, backups, and many more, while preserving your investments in your MongoDB app. You can communicate with the Azure Cosmos DB’s API for MongoDB by using any of the open-source MongoDB client drivers. The Azure Cosmos DB’s API for MongoDB enables the use of existing client drivers by adhering to the MongoDB wire protocol.

Let's create some code that will allow us to create a collection and define its sharding key and throughput.

1. In not already opened, open the Azure Cloud Shell.

1. Run the following command to open the code editor.

    ```bash
    cd ~/mslearn-cosmosdb/api-for-mongodb/01-create-mongodb-objects/java/AzureApp
    code ./src/main/java/com/fabrikam/App.java
    ```

1. Copy the following code and *replace the existing content* from the App.js file. *Don't forget that you'll need to replace the uri value for the connection string copied in step 2 of the previous section*. This part of the code uses the MongoDB drivers and uses the connection string to Azure Cosmos DB like you would normally use a connection string to any MongoDB server.  The code then defines and opens the connection to the Azure Cosmos DB account.

    ```java
    package com.fabrikam;

    // Uses the MongoDB driver
    import com.mongodb.MongoClient;
    import com.mongodb.MongoClientURI;
    import com.mongodb.client.MongoDatabase;
    import com.mongodb.client.MongoCollection;
    import org.bson.Document;
    import static com.mongodb.client.model.Filters.eq;

    public class App {
        public static void main(String[] args) {

            // Remember to replace below "YourAzureCosmosDBAccount" with the name of your Azure Cosmos DB 
            // account name and "YourAzureCosmosDBAccountKEY" with the Azure Cosmos DB account key.
            // Or replace is with the connection string if you have it.
            MongoClientURI uri = new MongoClientURI("mongodb://YourAzureCosmosDBAccount:YourAzureCosmosDBAccountKEY@YourAzureCosmosDBAccount.mongo.cosmos.azure.com:10255/?ssl=true&retrywrites=false&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@YourAzureCosmosDBAccount@");
    
            MongoClient mongoClient = null;
            try {
                // define the connection using the MongoClient method ane the url above and open the connection 
                mongoClient = new MongoClient(uri);
    
    ```

1. The next step connects to the **employees** database. Note that if this database doesn't exist it will create it only if also creates a collection in the same connection. Add the following to the script in the editor.

    ```java
                // connect to the database "employees"
                MongoDatabase EmployeeDatabase = mongoClient.getDatabase("employees");
    
    ```

1. So far it looks pretty much like the code in the previous section. In this step, we'll now take advantage of the extension commands and create a custom action.  This action will allow us to define the throughput and the sharding key of the collection, which will in turn give Azure Cosmos DB the parameters to use when creating the collection. Add the following to the script in the editor.

    ```java
                // create the Employee collection with a throughput of 400 RUs and with EmployeeId as the sharding key
                Document employeeCollectionDef = new Document();
                employeeCollectionDef.append("customAction", "CreateCollection");
                employeeCollectionDef.append("collection", "Employee");
                employeeCollectionDef.append("offerThroughput", 1000);
                employeeCollectionDef.append("shardKey", "EmployeeId");

                Document result = EmployeeDatabase.runCommand(employeeCollectionDef);
        
    ```

1. The rest will be pretty identical to the previous example, we will connect to the collection, insert some rows,  query and output a row back and finally close the collection. Add the following to the script in the editor.

    ```java
                // Connect to the collection "Employee" and add two items for "Marcos" and "Tam" 
                MongoCollection collection = EmployeeDatabase.getCollection("Employee");
    
                collection.insertOne(new Document()
                            .append("EmployeeId", 1)
                            .append("email","Marcos@fabrikam.com")
                            .append("name", "Marcos"));
    
                collection.insertOne(new Document()
                            .append("EmployeeId", 2)
                            .append("email","Tam@fabrikam.com")
                            .append("name", "Tam"));
    
                // return data where EmployeeId = 1
                Document findEmployee = (Document) collection.find(eq("EmployeeId", 1)).first();
                System.out.println(findEmployee.toJson());
            }
            // close the connection
            finally {
                if (mongoClient != null) {
                    mongoClient.close();
                }
            }
        }
    }
    ```

1. The script should look like this:

    ```java
    package com.fabrikam;

    // Uses the MongoDB driver
    import com.mongodb.MongoClient;
    import com.mongodb.MongoClientURI;
    import com.mongodb.client.MongoDatabase;
    import com.mongodb.client.MongoCollection;
    import org.bson.Document;
    import static com.mongodb.client.model.Filters.eq;

    public class App {
        public static void main(String[] args) {

            // Remember to replace below "YourAzureCosmosDBAccount" with the name of your Azure Cosmos DB 
            // account name and "YourAzureCosmosDBAccountKEY" with the Azure Cosmos DB account key.
            // Or replace is with the connection string if you have it.
            MongoClientURI uri = new MongoClientURI("mongodb://YourAzureCosmosDBAccount:YourAzureCosmosDBAccountKEY@YourAzureCosmosDBAccount.mongo.cosmos.azure.com:10255/?ssl=true&retrywrites=false&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@YourAzureCosmosDBAccount@");
    
            MongoClient mongoClient = null;
            try {
                // define the connection using the MongoClient method ane the url above and open the connection 
                mongoClient = new MongoClient(uri);
    
                // connect to the database "HumanResources"
                MongoDatabase EmployeeDatabase = mongoClient.getDatabase("HumanResources");
    
                // create the Employee collection with a throughput of 400 RUs and with EmployeeId as the sharding key
                Document employeeCollectionDef = new Document();
                employeeCollectionDef.append("customAction", "CreateCollection");
                employeeCollectionDef.append("collection", "Employee");
                employeeCollectionDef.append("offerThroughput", 1000);
                employeeCollectionDef.append("shardKey", "EmployeeId");

                Document result = EmployeeDatabase.runCommand(employeeCollectionDef);
        
                // Connect to the collection "Employee" and add two items for "Marcos" and "Tam" 
                MongoCollection collection = EmployeeDatabase.getCollection("Employee");
    
                collection.insertOne(new Document()
                            .append("EmployeeId", 1)
                            .append("email","Marcos@fabrikam.com")
                            .append("name", "Marcos"));
    
                collection.insertOne(new Document()
                            .append("EmployeeId", 2)
                            .append("email","Tam@fabrikam.com")
                            .append("name", "Tam"));
    
                // return data where EmployeeId = 1
                Document findEmployee = (Document) collection.find(eq("EmployeeId", 1)).first();
                System.out.println(findEmployee.toJson());
            }
            // close the connection
            finally {
                if (mongoClient != null) {
                    mongoClient.close();
                }
            }
        }
    }
    ```

1. Let's go ahead and save the Java program.  Select on the Upper right hand corner of the code editor and select **Save** (or Ctrl+S). Now select **Close Editor** (or Ctrl+Q) to go back to the Shell.

1. Let's now run the Java App with the following command.

    ```bash
    mvn clean compile exec:java
    ```  

1. This should return a similar result to the one below. As we mentioned at the beginning of this exercise, we're using *Maven* to build and compile this app.  You'll notice that this output is very chatty, this is normal since this output is usually piped to a log file. However towards the end, you should see this *INFO* message below with the JSON results of our **EmployeeId = 1** query in our code.  This means that we created the database, collection and added an item to it.

    ```json
    INFO: Opened connection [connectionId{localValue:3, serverValue:2080122971}] to learn-account-cosmos-845083734-westus.mongo.cosmos.azure.com:10255
    { "_id" : { "$oid" : "62afd8e2c471f3011bd415fe" }, "EmployeeId" : 1, "email" : "Marcos@fabrikam.com", "name" : "Marcos" }
    Jun 20, 2022 2:18:11 AM com.mongodb.diagnostics.logging.JULLogger log
    INFO: Closed connection [connectionId{localValue:3, serverValue:2080122971}] to learn-account-cosmos-845083734-westus.mongo.cosmos.azure.com:10255 because the pool has been closed.
        ```

1. However this last result set only confirmed that we indeed created a database, collection and items, but what about our shard key and throughput, did they really change? On the Cloud Shell let's run the following commands to verify our changes took effect.

    1. Let's verify that our Shard key changed to ***EmployeeId*** (the default is *id*).  *Don't forget to change the ***resource group name*** and ***account name*** for the names we saved at the beginning of this lab.*

        ```bash
        az cosmosdb mongodb collection show --name Employee --database-name HumanResources --resource-group learn-20c8df29-1419-49f3-84bb-6613f052b5ae --account-name learn-account-cosmos-845083734
        ```

        The result should include the property **"shardKey": {"EmployeeId": "Hash"}**.

    1. Let's verify that our Throughput changed to ***1000*** (the default is *400*).  *Don't forget to change the ***resource group name*** and ***account name*** for the names we saved at the beginning of this lab.*

        ```bash
        az cosmosdb mongodb collection throughput show --name Employee --database-name HumanResources --resource-group learn-20c8df29-1419-49f3-84bb-6613f052b5ae --account-name learn-account-cosmos-845083734
        ```

        The result should include the property **"throughput": 1000**.

This code illustrated the power of using extended commands in our code, which allows us to define the Azure Cosmos DB creation parameters.  This allows us to take advantage of controlling how our collections will be created and processed by Azure Cosmos DB.
