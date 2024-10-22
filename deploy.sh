#!/bin/bash

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Error: No version provided."
    echo "Usage: $0 <version> (like v1.0.0)"
    exit 1
fi

VERSION=$1

# Log the version being used for deployment
echo "Starting deployment with Docker image version $VERSION..."

# Terraform Initialization
echo "Initializing Terraform..."
terraform init

if [[ $? -ne 0 ]]; then
    echo "Error: Terraform init failed."
    exit 1
fi

# Apply the Terraform configuration, deploying the Docker image version
echo "Applying Terraform configuration with image version $VERSION..."
terraform apply -var="image_version=$VERSION" -auto-approve

if [[ $? -ne 0 ]]; then
    echo "Error: Terraform apply failed."
    exit 1
fi

echo "Deployment completed with Docker image version $VERSION."
