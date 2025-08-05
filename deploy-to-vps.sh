#!/bin/bash

# ==========================================
# Deploy to GitHub and VPS Script
# ==========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="shalomfr/smartsmart"           # המאגר שלך ב-GitHub
VPS_HOST="31.97.129.5"                      # כתובת ה-VPS שלך
VPS_USER="root"                              # משתמש ה-VPS
APP_DIR="/home/emailapp/email-app"          # תיקייה ב-VPS
PM2_APP_NAME="email-app-backend"            # שם האפליקציה ב-PM2

echo -e "${GREEN}=== Email App Deployment Script ===${NC}"

# Function to check if command was successful
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1 successful${NC}"
    else
        echo -e "${RED}✗ $1 failed${NC}"
        exit 1
    fi
}

# ==========================================
# PART 1: Push to GitHub
# ==========================================

echo -e "\n${YELLOW}Step 1: Pushing to GitHub...${NC}"

# Check if git is initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
    git remote add origin git@github.com:${GITHUB_REPO}.git
fi

# Add all files
git add .
check_status "Git add"

# Commit with timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
git commit -m "Deploy: ${TIMESTAMP}"
check_status "Git commit"

# Push to GitHub
git push -u origin main --force
check_status "Push to GitHub"

# ==========================================
# PART 2: Deploy to VPS
# ==========================================

echo -e "\n${YELLOW}Step 2: Deploying to VPS...${NC}"

# Create deployment script for VPS
cat > deploy-on-vps.sh << 'EOF'
#!/bin/bash

APP_DIR="/home/emailapp/email-app"
GITHUB_REPO="shalomfr/smartsmart"  # יעודכן דינמית

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting deployment on VPS...${NC}"

# Create app directory if not exists
mkdir -p $APP_DIR
cd $APP_DIR

# Clone or pull latest code
if [ ! -d .git ]; then
    echo "Cloning repository..."
    git clone https://github.com/${GITHUB_REPO}.git .
else
    echo "Pulling latest changes..."
    git pull origin main
fi

# Install frontend dependencies
echo -e "${YELLOW}Installing frontend dependencies...${NC}"
npm install

# Build frontend
echo -e "${YELLOW}Building frontend...${NC}"
npm run build

# Install backend dependencies
echo -e "${YELLOW}Installing backend dependencies...${NC}"
cd backend
npm install

# Create .env file if not exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << 'ENVFILE'
PORT=3001
NODE_ENV=production
ENVFILE
fi

# Restart application with PM2
echo -e "${YELLOW}Restarting application...${NC}"
pm2 delete email-app-backend 2>/dev/null || true
pm2 start server.js --name email-app-backend
pm2 save

# Start frontend server
cd $APP_DIR
pm2 delete email-app-frontend 2>/dev/null || true
pm2 serve dist 8080 --name email-app-frontend --spa
pm2 save

# Setup Nginx if not configured
if [ ! -f /etc/nginx/sites-available/email-app ]; then
    echo -e "${YELLOW}Configuring Nginx...${NC}"
    sudo tee /etc/nginx/sites-available/email-app > /dev/null << 'NGINX'
server {
    listen 80;
    server_name _;

    # Frontend
    location / {
        root /home/emailapp/email-app/dist;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX

    sudo ln -sf /etc/nginx/sites-available/email-app /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx
fi

echo -e "${GREEN}✓ Deployment completed successfully!${NC}"
EOF

# Update the GITHUB_REPO in the script
sed -i "s|GITHUB_REPO=\"your-username/your-repo-name\"|GITHUB_REPO=\"${GITHUB_REPO}\"|g" deploy-on-vps.sh

# Copy script to VPS and execute
echo "Copying deployment script to VPS..."
scp deploy-on-vps.sh ${VPS_USER}@${VPS_HOST}:/tmp/
check_status "Copy deployment script"

echo "Executing deployment on VPS..."
ssh ${VPS_USER}@${VPS_HOST} "bash /tmp/deploy-on-vps.sh"
check_status "VPS deployment"

# Cleanup
rm deploy-on-vps.sh

echo -e "\n${GREEN}=== Deployment Complete! ===${NC}"
echo -e "Your app should now be available at: ${YELLOW}http://${VPS_HOST}${NC}"