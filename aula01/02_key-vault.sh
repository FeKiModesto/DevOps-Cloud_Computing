#!/bin/bash

RESOURCE_GROUP="rg-money-hub"
LOCATION="eastus"
KEY_VAULT="keyvault-561810"
ACR_NAME="moneyhub561810"

az keyvault create \
  --resource-group $RESOURCE_GROUP \
  --name $KEY_VAULT \
  --location $LOCATION

az keyvault secret set --vault-name $KEY_VAULT --name "mysql-root-password" --value "root-dimdim"
az keyvault secret set --vault-name $KEY_VAULT --name "mysql-database" --value "db-dimdim"
az keyvault secret set --vault-name $KEY_VAULT --name "mysql-user" --value "user-dimdim"
az keyvault secret set --vault-name $KEY_VAULT --name "mysql-password" --value "senha-dimdim"
az keyvault secret set --vault-name $KEY_VAULT --name "spring-datasource-url" --value "jdbc:mysql://mysql-dimdim:3306/db-dimdim"
az keyvault secret set --vault-name $KEY_VAULT --name "acr-username" --value "$ACR_NAME"
az keyvault secret set --vault-name $KEY_VAULT --name "acr-password" --value "$(az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query passwords[0].value --output tsv)"

echo ""
echo "Key Vault criado: $KEY_VAULT"
echo ""
