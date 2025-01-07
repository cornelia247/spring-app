# Setup Documentation

## 1. Introduction

This document provides a step-by-step guide to deploying a cloud-based application using Terraform and GitHub Actions. The solution automates the provisioning of infrastructure and the deployment of a Dockerized application. The workflows can be found at `.github/workflows`.

### Key Workflows:
1. **Infrastructure Workflow (`infrastructure-deploy.yml`)**:  
   - Manages Terraform configurations to create, update, and deploy infrastructure across environments (e.g., dev, staging, prod).

2. **Application Workflow (`application-deploy.yml`)**:  
   - Packages, tests, and builds the application into a Docker image.
   - Pushes the Docker image to Amazon Elastic Container Registry (ECR).
   - Deploys the application to Elastic Container Service (ECS) using the infrastructure provisioned by the Terraform templates.
3. **Destroy Workflow (`destroy.yml`)**:
   - Cleans up all resources created by terraform.

The Terraform templates include components such as:
- Application Load Balancers (ALB)
- Elastic File System(EFS)
- Auto-scaling configurations
- CloudWatch monitoring
- Virtual Private Clouds (VPC)
- Security groups
- Elastic Container Service tasks
- A RDS database
- Amazon Elastic Container Registry (ECR)

---

## 2. Prerequisites

- AWS CLI 
- Ensure the CI/CD workflow has the necessary permissions to access your AWS environment using OpenID Connect (OIDC). OIDC allows your GitHub Actions workflows to access resources in Amazon Web Services (AWS), without needing to store the AWS credentials as long-lived GitHub secrets. You can check out this github [documentation](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) on how to set up OIDC on your cloud environment.

---

## 3. Forking the Repository
### Steps:

1. **Fork the Repository**:
   - Click the "Fork" button at the top right corner of the repository page.
   - Select your GitHub account to create a forked copy.

2. **Clone the Forked Repository**:
   - Copy the URL of your forked repository.
   - Use the following command to clone it locally:
     ```bash
     git clone <your-forked-repository-url>
     ```
3. The infrastructure provisioning and application deployment for different environment are tied to the branches they are at i.e: dev branch deployments will deploy "dev" environment configuration, staging and main will do similar. Note main branch will deploy "prod" environment.
  
4. Create the Branches
   
  - **To create a branch in the GitHub repository**:
    1. Go to the **Code** tab.
    2. Click on the **Branch** dropdown.
    3. Start typing the name of the new branch and select the option to create it.
    4. Ensure the new branch is created **from the `main` branch**.
  
  - **To create and switch to the branch in your local environment**, use the following command:
    ```bash
    git checkout -b staging
---

## 4. Configuring the Solution
### Steps:
1. **Set Up the S3 Backend**:
   Effectively managing your Terraform state is essential for maintaining infrastructure integrity and enabling smooth collaboration. Storing the Terraform state in an S3 bucket and utilizing DynamoDB for state locking ensures consistent and reliable infrastructure management, even in team settings.
   
   - Create an S3 bucket to store the Terraform state:
     ```bash
     aws s3api create-bucket --bucket <your-bucket-name> --region <region-name>
     ```
   - Example:
     ```bash
     aws s3api create-bucket --bucket your-terraform-state-bucket --region us-east-1
     ```
   - Create a DynamoDB table for state locking:
     ```bash
     aws dynamodb create-table \
      --table-name <your-table-name> \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
     ```

2. **Update the `infrastructure/backend.tf` File**:
   - Add the following configuration:
     ```hcl
     terraform {
       backend "s3" {
         bucket         = "your-bucket-name"
         key            = "newterraform/state"
         region         = "your-region"
         dynamodb_table = "your-table-name"
       }
     }
     ```

3. **Configure Environment Variables in `infrastructure/<environment>.tfvars` files**:
   - Set the required environment-specific variables e.g:
     ```hcl
     env = "dev"
     vpc_cidr_block        = "" # Example: "10.16.0.0/16". Plan CIDR blocks to avoid IP conflicts.
     ```
---

## 5. Deploying with Infrastructure CI/CD Pipeline

### Configure your Repository Secrets:
The Infrastructure workflow relies on specific variables and secrets for a successful run. In the `infrastructure-deploy.yml` workflow, the following secrets, variables and environments are required:
#### Secrets
- `YOUR_AWS_ACCOUNT_ID`
- `YOUR_AWS_GITHUB_ROLE`
#### Environments
- `production`
- `destroy`

### How to Configure a Secret in a GitHub Repository:
1. Navigate to the chosen repository.
2. Under your repository name, click **Settings**. If you cannot see the "Settings" tab, select the **...** dropdown menu, then click **Settings**.
3. In the **Security** section of the sidebar, select **Secrets and variables**, then click **Actions**.
4. Go to the **Secrets** tab and click **New repository secret**.
   - Add `YOUR_AWS_ACCOUNT_ID` as the name and your AWS Account ID as the value, then click **Add secret**.
   - Repeat the same process for `YOUR_AWS_GITHUB_ROLE`.
  
### How to Configure Environments in a GitHub Repository:
1. Navigate to the chosen repository.
2. Under your repository name, click **Settings**. If you cannot see the "Settings" tab, select the **...** dropdown menu, then click **Settings**.
3. In the left sidebar, under the **Deployments** section, select **Environments**.
4. Click **New environment** to create a new environment.
   - Add the environment name, e.g., `production` or `destroy`.
5. Configure the environment settings:
   - **Required Approvals**: Enable this option to add approval rules before workflows can deploy to this environment.
6. Click **Save** to finalize the environment configuration.

### Deploying Your Infrastructure:
- After configuring your `<branch-name>.tfvars` file and adding the required secrets, you can deploy your app by pushing the chosen environment's branch to your GitHub repo.
- navigate to the Actions tab to view your running workflow.
- The terraform is configured to output a host Name of the loadbalancer please keep an eye out for it. The hostname for the ALB will be displayed after deployment. Use this hostname to access your application

---

## 6. Deploying the Application CI/CD Pipeline

  After your Infrastructure workflow has deployed successfully you can go ahead to deploy your `application-deploy.yml` workflow, your application workflow requires an additional variable:
- `PROJECT_NAME`
  
### How to Configure a Variable in a GitHub Repository:

  1. Basically follow the same steps on adding the secret in the previous section but instead of adding secrets at the **Secrets** tab, go to the  **Variables** tab and click **New repository variables**. Variables Store non-sensitive configuration values, not encrypted but intended for plain-text values and can be viewed in logs when referenced.
    - Add `PROJECT_NAME` as the name and your project name as the value, then click **Add variable**.
### Deploying Your Infrastructure:
#### Important Notes on Application Deployment:

  1. **Run the Infrastructure Pipeline First**:
     - The Infrastructure CI/CD pipeline (`infrastructure-deploy.yml`) must be successfully executed before running the Application CI/CD pipeline (`application-deploy.yml`). 
     - This ensures that all required infrastructure components—such as ECS clusters, load balancers, security groups, and networking configurations—are provisioned and available. Skipping this step can result in deployment failures as the application depends on the infrastructure to exist.
  
  2. **Purpose of the `PROJECT_NAME` Variable**:
     - The `PROJECT_NAME` variable is a key configuration in the Application pipeline. It specifies the name of the application or project being deployed.
     - This variable is used to tag resources, manage application-specific configurations, and structure your deployment artifacts in ECR and ECS.
     - For example:
       - A `PROJECT_NAME` of `my-app` will name the Docker image in ECR as `my-app:latest`.
       - ECS services and tasks will also reflect this naming convention for better traceability and management.
- After adding the required variable, you can deploy your app by pushing the chosen environment's branch to your GitHub repo.
- Navigate to the Actions tab to view your running workflow.

---

## 7. Next Steps
- Navigate to the host Name **alb_hostname** outputted by terraform after about 5 minutes to view your application, you can try logging in by using: `greg/turnquist` as credentials 

## 8. Grafana Monitoring Setup
The infrastructure includes a Grafana service deployed on ECS, configured to use CloudWatch as a data source for monitoring application logs, cluster metrics, and service metrics.

### Accessing Grafana
- Access the Grafana portal using the ALB DNS name (output from Terraform) on port 3000
  ```
  http://<alb-dns-name>:3000
  ```
- Login credentials:
  - Username: `admin`
  - Password: Retrieve from AWS Secrets Manager using the following command:
    ```bash
    aws secretsmanager get-secret-value \
        --secret-id <name of secret> \
        --query SecretString \
        --output text | jq -r '.password'
    ```
   - You can get the name of the grafana secret from the output of the terraform named **grafana_secret**

### Configuring CloudWatch Data Source
1. After logging in to Grafana:
   - Navigate to Configuration → Data Sources
   - Click "Add data source"
   - Select "CloudWatch"

2. Configure the CloudWatch data source:
   - Name: `CloudWatch` (or your preferred name)
   - Default Region: Select the AWS region where your resources are deployed
   - Authentication Provider: "AWS SDK Default"

3. Click "Save & Test" to verify the connection

### Setting Up Dashboards
1. Create a new dashboard:
   - Click the "+" icon in the sidebar
   - Select "New Dashboard"
   - Click "Add visualization"

2. Configure ECS Cluster Metrics:
   - Select "CloudWatch" as the data source
   - Namespace: AWS/ECS
   - Common metrics to monitor:
     - CPUUtilization
     - MemoryUtilization

3. Configure Application Logs:
   - Add a new panel
   - Select "CloudWatch Logs Insights" as the query type
   - Log group: Select your ECS task log group
   - Sample query for application logs:
     ```
     fields @timestamp, @message
     | sort @timestamp desc
     | limit 100
     ```

4. Save your dashboard:
   - Click the save icon in the top right
   - Give your dashboard a name
   - Click "Save"

## 9. Destroy Resources
- When ready to clean up your environment, you can run the `destroy.yml` workflow.
- Clean up your created S3 bucket and DynamoDB table using these commands:
- Example:
     ```bash
     # Delete all objects and in the S3 bucket
     aws s3 rm s3://<your-terraform-state-bucket> --recursive

     # Delete the S3 bucket
     aws s3api delete-bucket --bucket <your-terraform-state-bucket> --region <region-name>

     # Delete the DynamoDB table
     aws dynamodb delete-table --table-name <your-terraform-state-lock> --region <region-name>
     ```