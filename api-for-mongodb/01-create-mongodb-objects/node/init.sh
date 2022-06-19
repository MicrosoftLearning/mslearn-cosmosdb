# Update node to Version 14.0.0, since the MongoDB driver requires ver 10+
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
nvm install 14.0.0
npm install -g mongodb
npm link mongodb


# Create a MongoDB API account

# Variable block
ResourceGroup=$(az group list --query [].name --output tsv)
ServerVersion="4.0"
let "randomIdentifier=$RANDOM*$RANDOM"
location=$(az group list --query [].location --output tsv)
account="learn-account-cosmos-$randomIdentifier"

# Create a Cosmos account for MongoDB API
echo "Creating $account"
az cosmosdb create --name $account --resource-group $ResourceGroup --kind MongoDB --server-version $ServerVersion --default-consistency-level Eventual --enable-automatic-failover true --locations regionName="$location"

#Displaying the Connection String
ConnectionString=$(az cosmosdb keys list --name $account --resource-group $ResourceGroup --type connection-strings --query connectionStrings[0].connectionString --output tsv)
echo "***************** Connection String ************************"
echo $ConnectionString
echo "************************************************************"


