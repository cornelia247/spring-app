# High-Level Infrastructure Documentation

## Overview of the Solution
This solution is designed to automate the provisioning, deployment, and management of the infrastructure required for a cloud-based application. Using **Terraform** as the Infrastructure as Code (IaC) tool, the deployment pipeline ensures a **scalable**, **monitored**, and **secure** environment on **AWS**.

---

## Key Design Goals
1. **Automation**: A fully automated pipeline to provision infrastructure using Terraform.
2. **Scalability**: Infrastructure is configured to scale automatically based on demand.
3. **Security**: Resources are secured within a VPC, with controlled public access.
4. **Monitoring and Auditing**: CloudWatch is used for monitoring; actions are logged for auditing purposes.
5. **Multi-Account Support**: Infrastructure allows deployment across personal accounts using CI/CD pipeline configurations.
6. **Clean-Up Capability**: Terraform includes a destroy functionality to clean up all provisioned resources efficiently.

---

## Architecture Diagram

The architecture includes the following AWS resources, as shown below:

![Architecture Diagram](Infrastructure-Architecture.drawio.png)

---

## Solution Components

### 1. Virtual Private Cloud (VPC)
- **Purpose**: Provides a secure, isolated network environment.
- **Configuration**:
   - 2 **Public Subnets**: To host NAT Gateways and Application Load Balancer.
   - 2 **Private Subnets**: To host ECS services and the RDS database.
- **Why**: A VPC ensures resources remain private and secure while allowing controlled access to the internet.

---

### 2. Application Load Balancer (ALB)
- **Purpose**: Manages inbound traffic and distributes it evenly across ECS services.
- **Why**: ALB ensures high availability and fault tolerance.

---

### 3. Amazon ECS with AWS Fargate
- **Purpose**: Orchestrates containerized workloads without managing servers.
- **Configuration**:
   - **Auto Scaling**: ECS services scale dynamically based on resource usage (e.g., CPU and memory).
   - **Private Subnets**: ECS tasks run securely without direct internet exposure.
- **Why**: Fargate eliminates server management, ensuring efficient scaling and resource optimization.

---

### 4. Amazon RDS (PostgreSQL)
- **Purpose**: Managed database service for storing application data.
- **Configuration**:
   - **Private Subnet**: RDS is isolated from external access.
   - **Automatic Backups**: Ensures data durability.
- **Why**: RDS provides reliability, scalability, and built-in backups without operational overhead.

---

### 5. NAT Gateways
- **Purpose**: Allow ECS tasks and RDS to access external resources securely.
- **Why**: Ensures outbound traffic for updates while maintaining backend isolation.

---

### 6. Monitoring and Auditing
- **Amazon CloudWatch**:
   - Monitors ECS performance (e.g., CPU and memory usage).
   - Provides alarms and dashboards for resource visibility.
- **AWS CloudTrail**:
   - Tracks API calls for auditing and compliance.

---

### 7. CI/CD Pipeline
The deployment pipeline uses GitHub Actions with Terraform for Infrastructure as Code.

#### Workflow:
1. **Infrastructure Deployment**:
   - Triggered by a branch push (e.g., `dev`, `staging`, or `main`).
   - Secrets and variables are configured for multiple accounts.
   - Terraform provisions VPC, ALB, ECS, RDS, and associated resources.
2. **Cleanup Functionality**:
   - Terraform’s `destroy` command allows for full clean-up of resources:
     ```bash
     terraform destroy -var-file=dev.tfvars
     ```
3. **Scalability**:
   - ECS services auto-scale using CloudWatch metrics.

---

## Design Choices

1. **Terraform**:
   - Chosen for its cloud-agnostic nature, modularity, and state management with S3 and DynamoDB.

2. **AWS Fargate**:
   - Reduces operational overhead for container orchestration.

3. **RDS with PostgreSQL**:
   - Ensures managed, reliable database services.

4. **ALB**:
   - Ensures efficient traffic distribution and fault tolerance.

5. **Monitoring with CloudWatch**:
   - Provides real-time visibility and automated scaling triggers.

6. **VPC Architecture**:
   - Ensures network isolation for security.

---

## Scaling Functionality
- **ECS Auto Scaling**:
   - Dynamically adjusts the number of ECS tasks based on CloudWatch alarms (e.g., CPU usage > 70%).
- **RDS Scaling**:
   - Supports vertical scaling based on resource needs.

---

## Cleanup and Resource Management
- Terraform ensures efficient resource management with clean-up functionality