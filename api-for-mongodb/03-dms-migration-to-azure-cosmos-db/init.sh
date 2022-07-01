# Unzip collections
cd ~/mslearn-cosmosdb/data
unzip cosmic-works.zip
mv cosmic-works-v1 database-v1
mv cosmic-works-v2 database-v2
mv cosmic-works-v3 database-v3
mv cosmic-works-v4 database-v4
cd ~/mslearn-cosmosdb/api-for-mongodb/02-indexes-and-aggregation-pipelines

# Create a MongoDB API account

# Variable block
ResourceGroup=$(az group list --query [].name --output tsv)
ServerVersion="4.0"
let "randomIdentifier=$RANDOM*$RANDOM"
location=$(az group list --query [].location --output tsv)
account="learn-account-cosmos-$randomIdentifier"
storageAccount = "learn-cosmos-$randomIdentifier"

# Create a Cosmos account for MongoDB API
echo "Creating $account"
az cosmosdb create \
    --name $account \
    --resource-group $ResourceGroup \
    --kind MongoDB \
    --server-version $ServerVersion \
    --default-consistency-level Eventual \
    --enable-automatic-failover true \
    --locations regionName="$location"

# Create storage account and container
az storage account create \
  --name "$storageAccount" \
  --resource-group "$ResourceGroup" \
  --location ""$location"" \
  --sku Standard_RAGRS \
  --kind StorageV2

key=$(az storage account keys list -g  "$ResourceGroup" -n "$storageAccount" --query [0].value -o tsv)

az storage container create -n mongodbbackupdirectory \ 
    --account-name  "$storageAccount" 
    --account-key $key

# Get connection string
ConnectionString=$(az cosmosdb keys list --name $account --resource-group $ResourceGroup --type connection-strings --query connectionStrings[0].connectionString --output tsv)

#Displaying the Connection String, Account Name and Resource Group Name
echo "***************** Storage Account name ********************"
echo $storageAccount
echo "***********************************************************"
echo "**************  Cosmos DB Account name ********************"
echo $account
echo "***********************************************************"
echo "**************** Resource Group name **********************"
echo $ResourceGroup
echo "***********************************************************"
echo "***************** Connection String ***********************"
echo $ConnectionString
echo "***********************************************************"
