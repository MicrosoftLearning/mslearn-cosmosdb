from ast import arg
import pymongo
import argparse
import json

def parse_args():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('-cs','--connectionstring', default='no_connection_string')
    parser.add_argument('-d','--database', default='')
    parser.add_argument('-c','--collection', default='')
    return parser

def load_xml_file(JSON_path):
    JSONFile = open(JSON_path)
    JSONdata = json.load(JSONFile)
    JSONFile.close()
    return JSONdata



def create_databases(databasesMetaData, CosmosDBClient, databaseArgument, collectionArgument):
    for resource in databasesMetaData['resources']:
        for database in databasesMetaData['resources'][resource]:
            maxthroughput = 0

            databasename = database['name']

            if databaseArgument != '':
                if databasename != databaseArgument:
                    continue

            print(databasename)

            if 'maxThroughput' in database:
                maxthroughput = database['maxThroughput']
                if maxthroughput > 8000:
                    maxthroughput = 8000

            DatabaseList = CosmosDBClient.list_database_names()
            CosmosDBDatabase = CosmosDBClient[databasename]

            if databasename in DatabaseList:
                if  maxthroughput > 0:
                    CosmosDBDatabase.command({'customAction': "UpdateDatabase", 'database': databasename, 'offerThroughput': maxthroughput} )
            else:
                if maxthroughput == 0:
                    maxthroughput = 400
                CosmosDBDatabase.command({'customAction': "CreateDatabase", 'database': databasename, 'offerThroughput': maxthroughput} )
            if 'containers' in database:
                create_collections(CosmosDBDatabase,database['containers'],databasename, collectionArgument)

def create_collections(CosmosDBDatabase, collections,DatabaseName, collectionArgument):
    for collection in collections:
        collectionMaxThroughput = 0
        shardKey=''

        collectionname = collection["name"]

        if collectionArgument != '':
            if collectionname != collectionArgument:
                continue
                
        print(collectionname)

        CollectionList = CosmosDBDatabase.list_collection_names()

        if collectionname not in CollectionList:
            if 'pk' in collection:
                shardKey = collection["pk"].replace("/","")
                CosmosDBDatabase.command({'customAction': "CreateCollection", 'collection': collectionname, 'shardKey': shardKey} )
            else:
                CosmosDBDatabase.command({'customAction': "CreateCollection", 'collection': collectionname} )

        if 'maxThroughput' in collection:
            collectionMaxThroughput = collection["maxThroughput"]
            CosmosDBDatabase.command({'customAction': "UpdateCollection", 'collection': collectionname, 'offerThroughput': collectionMaxThroughput} )
        
        load_collection(CosmosDBDatabase, collectionname,DatabaseName)


def load_collection(CosmosDBDatabase, CollectionName,DatabaseName):
    CollectionFileName = "../../data/"+DatabaseName+"/"+CollectionName
    CollectionFile = load_xml_file(CollectionFileName)
    CosmosDBCollection = CosmosDBDatabase[CollectionName]

    CosmosDBCollection.insert_many(CollectionFile)

def main(args):

    # We use the "MongoClient" method and the "uri" value to connect to the account 
    client = pymongo.MongoClient(args.connectionstring)
    databaseArgument = args.database
    collectionArgument = args.collection

    # Get Cosmos DB Databases MetaData
    ConfigFile = load_xml_file('../../data/config.json')

    create_databases(ConfigFile, client, databaseArgument, collectionArgument)


  
    # Closing file

    #print(args.connectionstring)

    # We use the "MongoClient" method and the "uri" value to connect to the account 
    # client = pymongo.MongoClient(args.connectionstring)
   
    



if __name__ == '__main__':
    parser = parse_args()
    args = parser.parse_args()
    main(args)
