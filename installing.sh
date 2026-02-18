#!/bin/bash

# 1. Check for root/sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root or with sudo."
   exit 1
fi

# 2. Update and Install
echo "Updating package lists and installing Nginx, Tree, and Git..."
apt update -y
apt install nginx tree git -y

# 3. Backup and Clear existing nginx.conf
NGINX_DEST="/etc/nginx/nginx.conf"
BACKUP_CONF="/etc/nginx/nginx-back.conf"

if [ -f "$NGINX_DEST" ]; then
    echo "Backing up $NGINX_DEST to $BACKUP_CONF..."
    cp "$NGINX_DEST" "$BACKUP_CONF"
    
    echo "Emptying $NGINX_DEST..."
    > "$NGINX_DEST"
else
    echo "Warning: $NGINX_DEST not found, creating empty file."
    touch "$NGINX_DEST"
fi

# 4. Clone the Git Repository into /srv
REPO_URL="https://github.com/fhsinchy/nginx-handbook-projects.git"
TARGET_DIR="/srv/nginx-handbook-projects"

if [ -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR already exists. Skipping clone."
else
    echo "Cloning $REPO_URL into $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
fi

# 5. Move nginx.conf from the CURRENT script directory to /etc/nginx/
# $(dirname "$0") ensures we look in the folder where the script lives
LOCAL_CONF="$(dirname "$0")/nginx.conf"

if [ -f "$LOCAL_CONF" ]; then
    echo "Moving local $LOCAL_CONF to $NGINX_DEST..."
    cp "$LOCAL_CONF" "$NGINX_DEST"
    
    # 6. Test and Restart
    echo "Testing configuration..."
    if nginx -t; then
        systemctl restart nginx
        echo "Nginx restarted successfully."
    else
        echo "Nginx configuration test failed! Please check $NGINX_DEST"
    fi
else
    echo "Error: No 'nginx.conf' found in the current directory ($(pwd))."
    echo "Please ensure the file exists next to this script."
fi

echo "----------------------------------------"
echo "Process Complete."
