#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Log all output
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting EC2 User Data Script..."

# Update and upgrade
sudo apt update -y
sudo apt upgrade -y

# ------------------------------------------------------------------------------
# Install Docker and Docker Compose
# ------------------------------------------------------------------------------
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# ------------------------------------------------------------------------------
# Install Node.js 18
# ------------------------------------------------------------------------------
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# ------------------------------------------------------------------------------
# Install Jenkins (LTS)
# ------------------------------------------------------------------------------
# Add Java (Required for Jenkins)
sudo apt install -y fontconfig openjdk-17-jre

# Add Jenkins repository and key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# ------------------------------------------------------------------------------
# Application Setup
# ------------------------------------------------------------------------------
cd /home/ubuntu

# Clone the repository
# Using the user's actual GitHub repository
git clone https://github.com/sn9729/autoheal-deploy.git
cd autoheal-deploy

# Change ownership to ubuntu
sudo chown -R ubuntu:ubuntu /home/ubuntu/autoheal-deploy

# Create .env from example
cp .env.example .env

# Run docker-compose up
sudo -u ubuntu docker-compose up -d

# Setup cron for health monitor
sudo -u ubuntu bash scripts/setup_cron.sh

echo "User Data Script Completed successfully!"
