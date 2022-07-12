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
cd "$GitRoot/mslearn-cosmosdb/data"
unzip cosmic-works.zip
mv cosmic-works-v1 database-v1
mv cosmic-works-v2 database-v2
mv cosmic-works-v3 database-v3
mv cosmic-works-v4 database-v4
cd "$GitRoot/mslearn-cosmosdb/api-for-mongodb/02-indexes-and-aggregation-pipelines"

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
#  ResourceGroup="cosmos-learn-$randomIdentifier"
#  echo
#  echo "Creating Resource Group - $ResourceGroup"
#  echo
#  az group create --location $location --name $ResourceGroup
  ResourceGroup=$(az group list --query [0].name --output tsv)
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

# Create a Cosmos account for MongoDB API
echo "Creating $account"
az cosmosdb create --name $account --resource-group $ResourceGroup --kind MongoDB --server-version $ServerVersion --default-consistency-level Eventual --enable-automatic-failover true --locations regionName="$location"

# Get connection string
ConnectionString=$(az cosmosdb keys list --name $account --resource-group $ResourceGroup --type connection-strings --query connectionStrings[0].connectionString --output tsv)

# Install the MongoDB Python drivers
python -m pip install pymongo

# Load collection database-v1.customer
python load-data.py -d database-v1 -c customer -cs $ConnectionString

#Displaying the Connection String, Account Name and Resource Group Name
echo "**************  Cosmos DB Account name ********************"
echo $account
echo "***********************************************************"
echo "**************** Resource Group name **********************"
echo $ResourceGroup
echo "***********************************************************"
echo "***************** Connection String ***********************"
echo $ConnectionString
echo "***********************************************************"
