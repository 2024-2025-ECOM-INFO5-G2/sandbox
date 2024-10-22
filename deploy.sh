#!/bin/bash

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Error: No version provided."
    echo "Usage: $0 <version> (like v1.0.0)"
    exit 1
fi

VERSION=$1
IMAGE_NAME="ecommmm"
DOCKER_HUB_REPO="romainmiras/ecommmm"

# Assure-toi que tu es connecté à Docker Hub
docker login

# Login with docker before running this script

echo "Building Docker image with version $VERSION..."

./gradlew -Pprod clean bootJar

./gradlew -Pprod bootJar jibDockerBuild

if [[ $? -ne 0 ]]; then
    echo "Error: Gradle build failed."
    exit 1
fi

echo "Docker image built successfully."

# Vérifier si l'image Docker locale existe
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "Error: Local Docker image '$IMAGE_NAME' not found."
    exit 1
fi

echo "Pushing Docker image to Docker Hub..."

# Taguer l'image locale avec le tag de version
docker tag $IMAGE_NAME $DOCKER_HUB_REPO:$VERSION

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to tag Docker image with '$VERSION'."
    exit 1
fi

# Taguer l'image locale avec 'latest'
docker tag $IMAGE_NAME $DOCKER_HUB_REPO:latest

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to tag Docker image with 'latest'."
    exit 1
fi

# Pousser l'image avec le tag de version vers Docker Hub
docker push $DOCKER_HUB_REPO:$VERSION

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to push Docker image with '$VERSION'."
    exit 1
fi

# Pousser l'image avec le tag 'latest' vers Docker Hub
docker push $DOCKER_HUB_REPO:latest

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to push Docker image with 'latest'."
    exit 1
fi

echo "Docker image pushed successfully with tags '$VERSION' and 'latest'."

echo "Starting deployment..."

terraform init

if [[ $? -ne 0 ]]; then
    echo "Error: Terraform init failed."
    exit 1
fi

terraform apply -var="image_version=$VERSION" -auto-approve

if [[ $? -ne 0 ]]; then
    echo "Error: Terraform apply failed."
    exit 1
fi

echo "Deployment completed with version $VERSION."
