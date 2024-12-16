#!/bin/bash

set -e  # Exit immediately if any command fails

# Step 1: Use ENVIRONMENT provided by the pipeline
echo "Environment: $ENVIRONMENT"

# Construct secret name
SECRET_NAME="${ENVIRONMENT}-spring-db-credentials"
log "Fetching database credentials: $SECRET_NAME"

# Fetch and parse secrets with robust error handling
DB_SECRET=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --query SecretString \
    --output text \
    --region "${AWS_DEFAULT_REGION}") || error_exit "AWS Secrets Manager retrieval failed"

# Use jq for safe JSON parsing
DB_HOST=$(echo "$DB_SECRET" | jq -e -r '.db_host // empty') || error_exit "Failed to extract db_host"
DB_NAME=$(echo "$DB_SECRET" | jq -e -r '.db_name // empty') || error_exit "Failed to extract db_name"
DB_USER=$(echo "$DB_SECRET" | jq -e -r '.username // empty') || error_exit "Failed to extract username"
DB_PASSWORD=$(echo "$DB_SECRET" | jq -e -r '.password // empty') || error_exit "Failed to extract password"

# Base64 encode with URL-safe and no-wrap options
SPRING_DATASOURCE_URL=$(printf "jdbc:postgresql://%s:5432/%s" "$DB_HOST" "$DB_NAME" | base64 -w 0)
SPRING_DATASOURCE_USERNAME=$(printf "%s" "$DB_USER" | base64 -w 0)
SPRING_DATASOURCE_PASSWORD=$(printf "%s" "$DB_PASSWORD" | base64 -w 0)

# Kubernetes Secret preparation
K8S_SECRET_NAME="${ENVIRONMENT}-spring-db-credentials"
SECRET_FILE="secret.yaml"

log "Creating Kubernetes Secret manifest: $SECRET_FILE"
cp ./applications/manifests/secret.yaml "$SECRET_FILE"

# Use GNU sed for more consistent behavior across environments
sed -i "s|placeholder-name|$K8S_SECRET_NAME|g" "$SECRET_FILE"
sed -i "s|placeholder-url|$SPRING_DATASOURCE_URL|g" "$SECRET_FILE"
sed -i "s|placeholder-username|$SPRING_DATASOURCE_USERNAME|g" "$SECRET_FILE"
sed -i "s|placeholder-password|$SPRING_DATASOURCE_PASSWORD|g" "$SECRET_FILE"

# Step 5: Apply the Secret manifest
echo "Applying Kubernetes Secret from manifest file: $SECRET_FILE"
kubectl apply -f $SECRET_FILE

echo "Kubernetes Secret '$K8S_SECRET_NAME' has been successfully created/updated!"