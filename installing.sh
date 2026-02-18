#!/bin/bash

# 1. Check for root/sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root or with sudo."
   exit 1
fi

echo "Updating package lists..."
apt update -y

# 2. Install Nginx and Tree
echo "Installing Nginx and Tree..."
apt install nginx tree -y

# 3. Define paths
NGINX_CONF="/etc/nginx/nginx.conf"
BACKUP_CONF="/etc/nginx/nginx-back.conf"

# 4. Backup the existing nginx.conf
if [ -f "$NGINX_CONF" ]; then
    echo "Backing up nginx.conf to $BACKUP_CONF..."
    cp "$NGINX_CONF" "$BACKUP_CONF"
    
    # 5. Empty the nginx.conf file
    echo "Emptying $NGINX_CONF..."
    > "$NGINX_CONF"
else
    echo "Error: $NGINX_CONF not found. Installation might have failed."
    exit 1
fi

# 4. Clone the Git Repository into /srv
TARGET_DIR="/srv/nginx-handbook-projects"

if [ -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR already exists. Skipping clone."
else
    echo "Cloning repository into $TARGET_DIR..."
    git clone https://github.com/fhsinchy/nginx-handbook-projects.git "$TARGET_DIR"
fi

echo "----------------------------------------"
echo "Done! Nginx and Tree are installed."
echo "Backup created: $BACKUP_CONF"
echo "Original config cleared: $NGINX_CONF"
