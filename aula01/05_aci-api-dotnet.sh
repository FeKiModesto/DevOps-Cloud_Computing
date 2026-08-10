#!/bin/bash

RESOURCE_GROUP="rg-money-hub"
ACR_NAME="moneyhub561810"
MYSQL_IP="20.120.127.45"

ACR_PASSWORD=$(az acr credential show --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --query passwords[0].value --output tsv)

az container create \
  --resource-group $RESOURCE_GROUP \
  --name api-dotnet \
  --image moneyhub561810.azurecr.io/api-transacoes:v1 \
  --registry-login-server moneyhub561810.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --os-type Linux \
  --environment-variables \
    ConnectionStrings__DefaultConnection="server=$MYSQL_IP;port=3306;database=db-dimdim;user=user-dimdim;password=senha-dimdim" \
  --ports 8080 \
  --ip-address Public \
  --dns-name-label api-dotnet-561810 \
  --cpu 1 \
  --memory 1.5

echo ""
echo "ACI API .NET criado!"
echo ""
