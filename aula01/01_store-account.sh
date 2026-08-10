#!/bin/bash

RESOURCE_GROUP="rg-money-hub"
LOCATION="eastus"
STORAGE_ACCOUNT="volumedimdim561810"
FILE_SHARE="mysql-dimdim-volume"

az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --location $LOCATION \
  --sku Standard_LRS

STORAGE_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query "[0].value" --output tsv)

az storage share create \
  --name $FILE_SHARE \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY

echo ""
echo "Storage Account: $STORAGE_ACCOUNT"
echo "File Share: $FILE_SHARE"
echo "Storage Key: $STORAGE_KEY"
echo ""
