#!/bin/bash

set -e  # Exit immediately if any command fails

# Step 1: Use ENVIRONMENT provided by the pipeline
echo "Environment: $ENVIRONMENT"

# Step 2: Construct the Secrets Manager key dynamically
SECRET_NAME="${ENVIRONMENT}-spring-db-credentials"
echo "Fetching database credentials from AWS Secrets Manager using secret name: $SECRET_NAME"

# Fetch credentials from AWS Secrets Manager
DB_SECRET=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)

# Parse credentials using jq
DB_HOST=$(echo $DB_SECRET | jq -r '.db_host')
DB_NAME=$(echo $DB_SECRET | jq -r '.db_name')
DB_USER=$(echo $DB_SECRET | jq -r '.username')
DB_PASSWORD=$(echo $DB_SECRET | jq -r '.password')

# Check for empty variables
if [[ -z "$DB_HOST" || -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_PASSWORD" ]]; then
  echo "Error: One or more database credentials are empty. Please check the Secrets Manager key: $SECRET_NAME"
  exit 1
fi

# Step 3: Encode secrets into Base64
SPRING_DATASOURCE_URL=$(echo -n "jdbc:postgresql://$DB_HOST:5432/$DB_NAME" | base64)
SPRING_DATASOURCE_USERNAME=$(echo -n "$DB_USER" | base64)
SPRING_DATASOURCE_PASSWORD=$(echo -n "$DB_PASSWORD" | base64)

# Step 4: Use sed to update the Kubernetes Secret manifest
K8S_SECRET_NAME="${ENVIRONMENT}-spring-db-credentials"
SECRET_FILE="secret.yaml"

echo "Creating Kubernetes Secret manifest file: $SECRET_FILE"
cp ./applications/manifests/secret-template.yaml $SECRET_FILE

# Replace placeholders in the manifest file
sed -i "s|placeholder-name|$K8S_SECRET_NAME|g" $SECRET_FILE
sed -i "s|placeholder-url|$SPRING_DATASOURCE_URL|g" $SECRET_FILE
sed -i "s|placeholder-username|$SPRING_DATASOURCE_USERNAME|g" $SECRET_FILE
sed -i "s|placeholder-password|$SPRING_DATASOURCE_PASSWORD|g" $SECRET_FILE

# Step 5: Apply the Secret manifest
echo "Applying Kubernetes Secret from manifest file: $SECRET_FILE"
kubectl apply -f $SECRET_FILE

echo "Kubernetes Secret '$K8S_SECRET_NAME' has been successfully created/updated!"