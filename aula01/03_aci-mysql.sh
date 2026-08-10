#!/bin/bash

RESOURCE_GROUP="rg-money-hub"
ACR_NAME="moneyhub561810"
STORAGE_ACCOUNT="volumedimdim561810"
FILE_SHARE="mysql-dimdim-volume"

STORAGE_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query "[0].value" --output tsv)

ACR_PASSWORD=$(az acr credential show --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --query passwords[0].value --output tsv)

az container create \
  --resource-group $RESOURCE_GROUP \
  --name mysql-dimdim \
  --image moneyhub561810.azurecr.io/mysql-dimdim:v1 \
  --registry-login-server moneyhub561810.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --os-type Linux \
  --environment-variables \
    MYSQL_ROOT_PASSWORD=root-dimdim \
    MYSQL_DATABASE=db-dimdim \
    MYSQL_USER=user-dimdim \
    MYSQL_PASSWORD=senha-dimdim \
  --ports 3306 \
  --ip-address Public \
  --cpu 1 \
  --memory 1.5 \
  --azure-file-volume-account-name $STORAGE_ACCOUNT \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-share-name $FILE_SHARE \
  --azure-file-volume-mount-path /var/lib/mysql

echo ""
echo "ACI MySQL criado!"
echo ""
