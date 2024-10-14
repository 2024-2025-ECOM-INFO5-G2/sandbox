# Terraform and Deployment Documentation

## Introduction
This documentation provides an overview of the Terraform and deployment scripts used to provision and configure infrastructure on Microsoft Azure. The setup includes a Virtual Machine to host a web application with Nginx and Docker for application deployment.

## Prerequisites
Before you begin, ensure you have the following:
- **Terraform**: Installed and configured on your local machine.
- **Azure CLI**: Set up with your Azure credentials.
- **Docker**: For building and pushing images.
- **SSH Key Pair**: Required for accessing the VM.
- **Azure Subscription ID**: Required to provision resources on Azure.

## File Descriptions

### `.gitignore`
Defines files and directories to be ignored by git to prevent accidental commits of sensitive information like credentials.

### `deploy.sh`
A shell script for building the application Docker image, pushing it to Docker Hub, and applying the Terraform configuration to deploy the infrastructure.
- **Arguments**: Takes a version argument (e.g., `v1.0.0`).
- **Docker**: Builds the Docker image using Gradle, tags it with the version and `latest` tags, and pushes it to Docker Hub.
- **Terraform**: Initializes and applies the configuration to deploy the VM, using the Docker image version as a variable.

### `main.tf`
The main Terraform configuration file that provisions the following resources:
1. **Resource Group**: Organizes resources on Azure.
2. **Virtual Network and Subnet**: Provides a network for the VM.
3. **Network Security Group**: Configures inbound rules for SSH (22), HTTP (80), and HTTPS (443).
4. **Public IP Address**: Allows external access to the VM.
5. **Network Interface**: Connects the VM to the network.
6. **Linux Virtual Machine**: Provisions the VM with Ubuntu 22.04 and attaches the public IP. The VM is configured with Docker and Nginx.
   - **SSH Keys**: Uses the SSH key pair for secure access.
   - **Provisioners**: Uploads Docker and Nginx configurations and runs the `setup-vm.sh` script.

### `nginx.conf`
Configures Nginx for the application.
- **Server Block**: Listens on port 80 and forwards requests to the application server at `http://app:8080`.
- **Proxy Headers**: Passes necessary headers for proper request forwarding.

### `setup-vm.sh`
A shell script for setting up the VM environment after provisioning.
- **Updates**: Installs updates and dependencies.
- **Docker Setup**: Installs Docker, enables it, and adds the current user to the Docker group.
- **Application Deployment**: Runs the Docker Compose file to start the application container.

## Setup and Configuration

### Configuring Variables
The following variables need to be set in `main.tf` or provided during deployment:
- `pub_ssh_key`: Path to your public SSH key for VM access.
- `priv_ssh_key`: Path to your private SSH key for Terraform provisioners.
- `subscription_id`: Azure Subscription ID.

To obtain these:
1. **Azure Subscription ID**: Run `az account show --query id --output tsv` after logging in with Azure CLI.
2. **SSH Key Pair**: Generate with `ssh-keygen` if you don’t already have one.

### Deployment Steps
1. **Deploy the Application**:
   ```bash
   ./deploy.sh <version>  # Replace <version> with the desired version tag, e.g., v1.0.0
   ```
2. enter your subscription_id and your ssk_key.

### Cleaning Up
To destroy all resources created by this Terraform setup, run:
```bash
terraform destroy -auto-approve
```

## Troubleshooting
- **Terraform Apply Fails**: Ensure Azure credentials are set up correctly, and you have permission to create resources.
- **Docker Login Issues**: Make sure you’re authenticated to Docker Hub before running `deploy.sh`.
- **Nginx Not Responding**: Check the VM status and ensure Nginx is running with `sudo systemctl status nginx`.

## Additional Notes
- Customize `nginx.conf` as needed for your application.
- Add more security rules to the Network Security Group if required.

## Output
After successful deployment, you can access the application using the public IP address of the VM:
```bash
echo "Public IP Address:" $(terraform output public_ip)
```
