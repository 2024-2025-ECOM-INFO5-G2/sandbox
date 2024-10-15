#!/bin/bash

# Mise à jour et installation des dépendances
sudo apt update -y
sudo apt upgrade -y

sudo apt install micro -y

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Ajouter la clé GPG officielle de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Configurer le dépôt stable pour Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Activer Docker
sudo systemctl enable docker
sudo systemctl start docker

# Ajouter l'utilisateur courant au groupe Docker
sudo usermod -aG docker $USER
newgrp docker

# Lancer Docker au démarrage

docker compose -f /home/azureuser/docker/docker-compose.yml up

# Restart le container webserver

docker restart webserver
