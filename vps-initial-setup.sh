#!/bin/bash

# ==========================================
# VPS Initial Setup Script for Email App
# ==========================================
# Run this ONCE on a fresh Ubuntu VPS

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}   VPS Setup for Email App        ${NC}"
echo -e "${BLUE}==================================${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1 successful${NC}"
    else
        echo -e "${RED}✗ $1 failed${NC}"
        exit 1
    fi
}

# Update system
echo -e "\n${YELLOW}Updating system packages...${NC}"
apt update && apt upgrade -y
check_status "System update"

# Install basic tools
echo -e "\n${YELLOW}Installing basic tools...${NC}"
apt install -y curl wget git build-essential
check_status "Basic tools installation"

# Install Node.js (v18 LTS)
echo -e "\n${YELLOW}Installing Node.js...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs
check_status "Node.js installation"

# Verify Node.js installation
node_version=$(node -v)
npm_version=$(npm -v)
echo -e "${GREEN}Node.js version: $node_version${NC}"
echo -e "${GREEN}npm version: $npm_version${NC}"

# Install PM2 globally
echo -e "\n${YELLOW}Installing PM2...${NC}"
npm install -g pm2
check_status "PM2 installation"

# Setup PM2 to start on boot
pm2 startup systemd -u root --hp /root
check_status "PM2 startup configuration"

# Install Nginx
echo -e "\n${YELLOW}Installing Nginx...${NC}"
apt install -y nginx
check_status "Nginx installation"

# Remove default Nginx site
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

# Configure firewall
echo -e "\n${YELLOW}Configuring firewall...${NC}"
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 3001/tcp  # Backend API (for development)
echo "y" | ufw enable
check_status "Firewall configuration"

# Create application directory
echo -e "\n${YELLOW}Creating application directory...${NC}"
mkdir -p /home/emailapp/email-app
check_status "Directory creation"

# Install Certbot for SSL (optional)
echo -e "\n${YELLOW}Installing Certbot for SSL...${NC}"
apt install -y certbot python3-certbot-nginx
check_status "Certbot installation"

# Create a deploy user (optional - more secure than using root)
echo -e "\n${YELLOW}Creating deploy user...${NC}"
useradd -m -s /bin/bash deploy
usermod -aG sudo deploy
check_status "Deploy user creation"

# Create emailapp user if not exists
if ! id -u emailapp > /dev/null 2>&1; then
    useradd -m -s /bin/bash emailapp
fi

# Give emailapp user access to app directory
chown -R emailapp:emailapp /home/emailapp/email-app

# Create swap file (helpful for low-memory VPS)
echo -e "\n${YELLOW}Creating swap file...${NC}"
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    check_status "Swap file creation"
else
    echo "Swap file already exists"
fi

# System optimization
echo -e "\n${YELLOW}Optimizing system...${NC}"
# Increase file watch limit for Node.js
echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
sysctl -p

# Create deployment info file
cat > /root/deployment-info.txt << EOF
=== Email App VPS Setup Complete ===

Important Information:
- Node.js $(node -v) installed
- PM2 installed and configured
- Nginx installed
- Firewall configured (ports: 22, 80, 443, 3001)
- Application directory: /home/emailapp/email-app
- Deploy user created: deploy

Next Steps:
1. Add your SSH key to the deploy user:
   ssh-copy-id deploy@$(curl -s ifconfig.me)

2. Configure your deployment script with:
   - VPS_HOST=$(curl -s ifconfig.me)
   - VPS_USER=deploy (or root)

3. Run the deployment script from your local machine

4. For SSL certificate (after domain is pointed):
   certbot --nginx -d yourdomain.com

5. Monitor your app:
   pm2 status
   pm2 logs email-app
   pm2 monit

Useful Commands:
- Restart app: pm2 restart email-app
- View logs: pm2 logs email-app
- Nginx logs: tail -f /var/log/nginx/error.log
- System resources: htop
EOF

echo -e "\n${GREEN}==================================${NC}"
echo -e "${GREEN}✓ VPS Setup Complete!${NC}"
echo -e "${GREEN}==================================${NC}"
echo -e "\n${YELLOW}Setup information saved to: /root/deployment-info.txt${NC}"
echo -e "${YELLOW}Your VPS IP: $(curl -s ifconfig.me)${NC}"
echo -e "\n${BLUE}You can now run the deployment script from your local machine${NC}"