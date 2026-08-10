#!/bin/bash

RESOURCE_GROUP="rg-money-hub"
ACR_NAME="moneyhub561810"
MYSQL_IP="20.120.127.45"

ACR_PASSWORD=$(az acr credential show --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --query passwords[0].value --output tsv)

az container create \
  --resource-group $RESOURCE_GROUP \
  --name api-java \
  --image moneyhub561810.azurecr.io/api-dimdim:v1 \
  --registry-login-server moneyhub561810.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --os-type Linux \
  --environment-variables \
    SPRING_DATASOURCE_URL=jdbc:mysql://$MYSQL_IP:3306/db-dimdim \
    SPRING_DATASOURCE_USERNAME=user-dimdim \
    SPRING_DATASOURCE_PASSWORD=senha-dimdim \
  --ports 8080 \
  --ip-address Public \
  --cpu 1 \
  --memory 1.5

echo ""
echo "ACI API Java criado!"
echo ""
