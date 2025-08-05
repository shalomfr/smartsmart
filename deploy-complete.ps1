# PowerShell Deployment Script for Email App
# ==========================================

$ErrorActionPreference = "Stop"

# Configuration
$GITHUB_REPO = "shalomfr/smartsmart"
$VPS_HOST = "31.97.129.5"
$VPS_USER = "root"
$APP_DIR = "/home/emailapp/email-app"

Write-Host "=== Email App Deployment (PowerShell) ===" -ForegroundColor Green
Write-Host ""

# Function to check command status
function Check-Status {
    param($Message)
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $Message successful" -ForegroundColor Green
    } else {
        Write-Host "✗ $Message failed" -ForegroundColor Red
        exit 1
    }
}

# Part 1: Push to GitHub
Write-Host "[1/4] Adding files to git..." -ForegroundColor Yellow
git add .
Check-Status "Git add"

Write-Host "[2/4] Committing changes..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Deploy: $timestamp"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] Nothing to commit or commit failed" -ForegroundColor Yellow
}

Write-Host "[3/4] Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "Trying with force push..." -ForegroundColor Yellow
    git push -u origin main --force
    Check-Status "Force push"
} else {
    Check-Status "Push to GitHub"
}

Write-Host ""
Write-Host "[SUCCESS] Code pushed to GitHub!" -ForegroundColor Green
Write-Host ""

# Part 2: Deploy to VPS
Write-Host "[4/4] Deploying to VPS..." -ForegroundColor Yellow

# Create deployment script
$deployScript = @'
#!/bin/bash

APP_DIR="/home/emailapp/email-app"
GITHUB_REPO="shalomfr/smartsmart"

echo "Starting deployment on VPS..."

# Navigate to app directory
cd $APP_DIR

# Pull latest changes
echo "Pulling latest changes..."
git pull origin main

# Install and build frontend
echo "Installing frontend dependencies..."
npm install

echo "Building frontend..."
npm run build

# Install backend
echo "Installing backend dependencies..."
cd backend
npm install

# Create .env if not exists
if [ ! -f .env ]; then
    echo "PORT=3001" > .env
    echo "NODE_ENV=production" >> .env
fi

# Restart backend with PM2
echo "Restarting backend..."
pm2 delete email-app-backend 2>/dev/null || true
pm2 start server.js --name email-app-backend
pm2 save

# Start frontend with PM2
echo "Starting frontend..."
cd $APP_DIR
pm2 delete email-app-frontend 2>/dev/null || true
pm2 serve dist 8080 --name email-app-frontend --spa
pm2 save

echo "Deployment completed successfully!"
'@

# Save deployment script to temp file
$tempFile = [System.IO.Path]::GetTempFileName() + ".sh"
$deployScript | Out-File -FilePath $tempFile -Encoding UTF8 -NoNewline

# Upload and execute
Write-Host "Uploading deployment script..." -ForegroundColor Yellow
scp $tempFile "${VPS_USER}@${VPS_HOST}:/tmp/deploy-script.sh"
Check-Status "Upload script"

Write-Host "Executing deployment on VPS..." -ForegroundColor Yellow
ssh "${VPS_USER}@${VPS_HOST}" "chmod +x /tmp/deploy-script.sh && bash /tmp/deploy-script.sh && rm /tmp/deploy-script.sh"
Check-Status "VPS deployment"

# Cleanup
Remove-Item $tempFile

Write-Host ""
Write-Host "===================================" -ForegroundColor Green
Write-Host "   Deployment Complete!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your app is available at: http://$VPS_HOST" -ForegroundColor Yellow
Write-Host ""
Write-Host "Useful commands on VPS:" -ForegroundColor Cyan
Write-Host "- Check status: pm2 status"
Write-Host "- View logs: pm2 logs"
Write-Host "- Backend logs: pm2 logs email-app-backend"
Write-Host "- Frontend logs: pm2 logs email-app-frontend"
Write-Host "- Restart all: pm2 restart all"
Write-Host ""