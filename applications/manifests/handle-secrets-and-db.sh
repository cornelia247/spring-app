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

# Step 3: Check if the database exists and create it if it doesn’t
echo "Checking if database '$DB_NAME' exists on host '$DB_HOST'..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';" | grep -q 1 || {
  echo "Database '$DB_NAME' does not exist. Creating it now..."
  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -c "CREATE DATABASE \"$DB_NAME\";"
  echo "Database '$DB_NAME' created successfully!"
}

# Step 4: Encode secrets into Base64
SPRING_DATASOURCE_URL=$(echo -n "jdbc:postgresql://$DB_HOST:5432/$DB_NAME" | base64)
SPRING_DATASOURCE_USERNAME=$(echo -n "$DB_USER" | base64)
SPRING_DATASOURCE_PASSWORD=$(echo -n "$DB_PASSWORD" | base64)

# Step 5: Create Kubernetes Secret with the required environment variables
K8S_SECRET_NAME="${ENVIRONMENT}-spring-db-credentials"
echo "Creating Kubernetes Secret with name: $K8S_SECRET_NAME"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: $K8S_SECRET_NAME
type: Opaque
data:
  SPRING_DATASOURCE_URL: $SPRING_DATASOURCE_URL
  SPRING_DATASOURCE_USERNAME: $SPRING_DATASOURCE_USERNAME
  SPRING_DATASOURCE_PASSWORD: $SPRING_DATASOURCE_PASSWORD
EOF

echo "Kubernetes Secret '$K8S_SECRET_NAME' has been successfully created/updated!"