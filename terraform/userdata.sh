#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting EC2 User Data Script..."

# Add 512MB Swap Space to prevent memory crashes
sudo fallocate -l 512M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y curl ca-certificates gnupg git docker.io docker-compose fontconfig openjdk-21-jre
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu

# Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Jenkins (trusted repo for faster install)
echo "deb [trusted=yes] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y || true
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
sudo usermod -aG docker jenkins

cd /home/ubuntu
git clone https://github.com/sn9729/autoheal-deploy.git
cd autoheal-deploy
sudo chown -R ubuntu:ubuntu /home/ubuntu/autoheal-deploy

if [ -z "${mongo_uri}" ] || [ "${mongo_uri}" = "REPLACE_ME" ]; then
  echo "ERROR: mongo_uri is not set. Update terraform.tfvars with your Atlas URI." | tee -a /var/log/user-data.log
  exit 1
fi

cat > .env <<EOF
MONGO_URI=${mongo_uri}
SESSION_SECRET=${session_secret}
PORT=3000
NODE_ENV=${node_env}
EOF

# Run Docker Compose as root to avoid docker group membership timing issues
docker-compose up -d
# Configure auto-heal cron as root so it can restart Docker containers
bash scripts/setup_cron.sh

echo "User Data Script Completed successfully!"
