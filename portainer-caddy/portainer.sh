#!/bin/bash

# Clear console
clear

# Initial banner
echo -e "\033[1;36m==============================================\033[0m"
echo -e "\033[1;32m|           Welcome to the VPS Setup         |\033[0m"
echo -e "\033[1;36m|                Powered by Xig0n            |\033[0m"
echo -e "\033[1;36m==============================================\033[0m\n"

# Request subdomain
echo -en "\e[32mPlease enter the portainer subdomain: \e[0m"
read SUBDOMAIN

# Confirm entered subdomain
echo -e "\nPlease confirm that the subdomain you entered is correct"
echo -e "Subdomain: \e[32m$SUBDOMAIN\e[0m"

read -p "Is the entered subdomain correct? (Y/N): " CONFIRM

while [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]; do
  clear
  echo -e "\e[32mPlease enter the subdomain: \e[0m"
  read SUBDOMAIN

  # Confirm entered subdomain
  echo -e "\nPlease confirm that the subdomain you entered is correct"
  echo -e "Subdomain: \e[32m$SUBDOMAIN\e[0m"

  read -p "Is the entered subdomain correct? (Y/N): " CONFIRM
done

# Clear console
clear

# Banner for VPS preparation
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;32m|  Step 1: Preparing the VPS environment...  |\033[0m"
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;33m- Installing required packages and dependencies.\033[0m"
echo -e "\033[1;33m- Configuring firewall settings for HTTP and HTTPS.\033[0m"

# Prepare VPS environment
sudo apt-get -yqqq update >/dev/null 2>&1
sudo apt-get -yqqqq install sudo curl nano zip htop unzip wget >/dev/null 2>&1
sudo apt-get -yqqq clean >/dev/null 2>&1
sudo apt-get -yqqq autoclean >/dev/null 2>&1
sudo rm -rf /var/cache/apk/*
sudo apt -yqqq autoremove --purge snapd >/dev/null 2>&1
sudo ufw allow 80/tcp comment 'accept HTTP caddy port' >/dev/null 2>&1
sudo ufw allow 443/tcp comment 'accept HTTPS caddy port' >/dev/null 2>&1
clear

# Banner for Docker installation
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;32m|  Step 2: Installing Docker...              |\033[0m"
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;33m- Setting up Docker to manage containers and services.\033[0m"
echo -e "\033[1;33m- Creating a custom Docker network.\033[0m"

# Install Docker
sudo curl -fsSL https://get.docker.com -o get-docker.sh; sudo sh get-docker.sh 2>dev>null;
sudo docker network create --driver bridge caddy;
sudo service docker start 2>dev>null;
sudo systemctl start docker 2>dev>null;
clear

# Banner for Caddy installation
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;32m|  Step 3: Installing Caddy...               |\033[0m"
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;33m- Deploying Caddy as a reverse proxy and web server.\033[0m"
echo -e "\033[1;33m- Configuring HTTPS and automated TLS.\033[0m"

# Install Caddy
sudo docker run -d \
  --name caddy \
  --network caddy \
  -p 80:80 \
  -p 443:443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v caddy_data:/data \
  --restart unless-stopped \
  -e CADDY_INGRESS_NETWORKS=caddy \
  lucaslorentz/caddy-docker-proxy
clear

# Banner for Portainer installation
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;32m|  Step 4: Installing Portainer...           |\033[0m"
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;33m- Setting up Portainer for container management.\033[0m"
echo -e "\033[1;33m- Exposing Portainer on subdomain: \e[32m$SUBDOMAIN\e[0m"

# Install Portainer
sudo docker run -d \
  --name portainer \
  --restart always \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --network=caddy \
  --label caddy=$SUBDOMAIN \
  --label caddy.reverse_proxy="{{upstreams 9000}}" \
  portainer/portainer-ce:latest
clear

# Banner for finalization
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;32m|  Step 5: Finalizing the installation...    |\033[0m"
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;33m- Waiting for Portainer to fully initialize.\033[0m"
echo -e "\033[1;33m- This process may take a few moments.\033[0m"

# Wait for Portainer to initialize
sleep 15
clear

# Final message
echo -e "\n\033[1;31m==============================================\033[0m"
echo -e "\033[1;32m|           Setup is complete!               |\033[0m"
echo -e "\033[1;31m==============================================\033[0m\n"
echo -e "\033[1;33m Access Portainer at: \033[0m\e[32mhttps://$SUBDOMAIN\e[0m\n"

# Final banner
echo -e "\033[1;34m==============================================\033[0m"
echo -e "\033[1;32m|   Thank you for using this setup script!   |\033[0m"
echo -e "\033[1;34m|                Powered by Xig0n            |\033[0m"
echo -e "\033[1;34m==============================================\033[0m\n"