ResourceGroupParameter=""
LocationParameter=""

while getopts r:l: flag
do
    case "${flag}" in
        r) ResourceGroupParameter=${OPTARG};;
        l) LocationParameter=${OPTARG};;
    esac
done

GitRoot=$(pwd)

# Unzip collections
cd "$GitRoot/data"
unzip dump.zip
cd ..

# Create a MongoDB API account

# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"

if [[ "$LocationParameter" == "" ]]
then
#  location=$(az account list-locations --query "[$(( ( RANDOM % 20) + 1 ))].name" -o tsv)
  locationarray=("eastus" "eastus2" "centralus" "westus" "westus2")
  location="${locationarray[ ( $RANDOM % 5) ]}"
else
  location="$LocationParameter"
fi

if [[ "$ResourceGroupParameter" == "" ]]
then
  ResourceGroup="cosmos-learn-$randomIdentifier"
  echo
  echo "Creating Resource Group - $ResourceGroup"
  echo
  az group create --location $location --name $ResourceGroup
else
  ResourceGroup="$ResourceGroupParameter"
  if [[ $LocationParameter == "" ]]
  then
    location=$(az group list --query "[?name=='$ResourceGroup'].location" --output tsv)
#    locationarray=("eastus" "eastus2" "centralus" "westus" "westus2")
#    location="${locationarray[ ( $RANDOM % 5) ]}"
  fi
fi

ServerVersion="4.0"
account="learn-account-cosmos-$randomIdentifier"
storageAccount="learncosmos$randomIdentifier"

# Create a Cosmos account for MongoDB API
echo
echo "Creating Azure CosmoDB account - $account"
echo

az cosmosdb create \
    --name $account \
    --resource-group $ResourceGroup \
    --kind MongoDB \
    --server-version $ServerVersion \
    --default-consistency-level Eventual \
    --enable-automatic-failover true \
    --locations regionName="$location"

# Create storage account and container
echo
echo "Creating Azure Storage account - $account"
echo

az storage account create --name $storageAccount --resource-group $ResourceGroup --location "$location" --sku Standard_RAGRS --kind StorageV2

storageaccountkey=$(az storage account keys list -g  "$ResourceGroup" -n "$storageAccount" --query [0].value -o tsv)

az storage container create --name mongodbbackupdirectory --account-name  $storageAccount --account-key $storageaccountkey

#echo
#echo "Upgrage storage extension if needed"
#echo
#az extension add --upgrade -n storage-preview

echo
echo "Copy backup files to Storage Account"
echo


sasurl=https://$storageAccount.blob.core.windows.net/mongodbbackupdirectory?$(az storage container generate-sas \
    --account-name $storageAccount \
    --name mongodbbackupdirectory \
    --permissions acdlrw \
    --expiry $(date +%Y-%m-%dT%H:%M:%SZ -ud "$date + 1 day") \
    --auth-mode key \
    --account-key $storageaccountkey)

#getting rid of the double quoutes insinde the string
sasurl="${sasurl//\"/}"

./azcopy copy "./data/dump/database-v*" "$sasurl" --recursive=true

# Get connection string
ConnectionString=$(az cosmosdb keys list --name $account --resource-group $ResourceGroup --type connection-strings --query connectionStrings[0].connectionString --output tsv)

SubscriptionID=$(az account show --query "{ subscriptionid: id }"  -o tsv)

SubscriptionName=$(az account show --query "{ name: name}"  -o tsv)

#Displaying the Connection String, Account Name and Resource Group Name
echo "***************** Storage Account name ********************"
echo $storageAccount
echo "***********************************************************"
echo "******************** Subcription ID ***********************"
echo $SubscriptionID
echo "***********************************************************"
echo "******************* Subcription Name **********************"
echo $SubscriptionName
echo "***********************************************************"
echo "******************** Location Name ***********************"
echo $location
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
