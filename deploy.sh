#!/bin/bash

# Log the version being used for deployment
echo "Starting deployment with the 'latest' Docker image..."

# Terraform Initialization
echo "Initializing Terraform..."
terraform init

if [[ $? -ne 0 ]]; then
    echo "Error: Terraform init failed."
    exit 1
fi

# Apply the Terraform configuration, deploying the Docker image with 'latest' tag
echo "Applying Terraform configuration with image version 'latest'..."
terraform apply -var="image_version=latest" -auto-approve

if [[ $? -ne 0 ]]; then
    echo "Error: Terraform apply failed."
    exit 1
fi

echo "Deployment completed with the 'latest' Docker image."
