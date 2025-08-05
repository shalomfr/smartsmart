@echo off
REM ==========================================
REM Deploy to GitHub and VPS - Windows Version
REM ==========================================

setlocal EnableDelayedExpansion

REM Configuration
set GITHUB_REPO=shalomfr/smartsmart
set VPS_HOST=31.97.129.5
set VPS_USER=root
set APP_DIR=/home/emailapp/email-app

echo.
echo ===================================
echo   Email App Deployment (Windows)
echo ===================================
echo.

REM Part 1: Push to GitHub
echo [1/4] Adding files to git...
git add .
if errorlevel 1 (
    echo [ERROR] Git add failed!
    pause
    exit /b 1
)

echo [2/4] Committing changes...
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/: " %%a in ('time /t') do (set mytime=%%a:%%b)
git commit -m "Deploy: %mydate% %mytime%"
if errorlevel 1 (
    echo [WARNING] Nothing to commit or commit failed
)

echo [3/4] Pushing to GitHub...
git push -u origin main
if errorlevel 1 (
    echo [ERROR] Push to GitHub failed!
    echo Trying with force push...
    git push -u origin main --force
    if errorlevel 1 (
        echo [ERROR] Force push also failed!
        pause
        exit /b 1
    )
)

echo.
echo [SUCCESS] Code pushed to GitHub!
echo.

REM Part 2: Deploy to VPS
echo [4/4] Deploying to VPS...
echo.

REM Create deployment script
echo Creating deployment script...
(
echo #!/bin/bash
echo.
echo APP_DIR="%APP_DIR%"
echo GITHUB_REPO="%GITHUB_REPO%"
echo.
echo echo "Starting deployment on VPS..."
echo.
echo # Create directory
echo mkdir -p $APP_DIR
echo cd $APP_DIR
echo.
echo # Clone or pull
echo if [ ! -d .git ]; then
echo     echo "Cloning repository..."
echo     git clone https://github.com/${GITHUB_REPO}.git .
echo else
echo     echo "Pulling latest changes..."
echo     git pull origin main
echo fi
echo.
echo # Install and build frontend
echo echo "Installing frontend dependencies..."
echo npm install
echo.
echo echo "Building frontend..."
echo npm run build
echo.
echo # Install backend
echo echo "Installing backend dependencies..."
echo cd backend
echo npm install
echo.
echo # Create .env if not exists
echo if [ ! -f .env ]; then
echo     cat ^> .env ^<^< 'EOF'
echo PORT=3001
echo NODE_ENV=production
echo EOF
echo fi
echo.
echo # Restart backend with PM2
echo echo "Restarting backend..."
echo pm2 delete email-app-backend 2^>/dev/null ^|^| true
echo pm2 start server.js --name email-app-backend
echo pm2 save
echo.
echo # Start frontend with PM2
echo echo "Starting frontend..."
echo cd $APP_DIR
echo pm2 delete email-app-frontend 2^>/dev/null ^|^| true
echo pm2 serve dist 8080 --name email-app-frontend --spa
echo pm2 save
echo.
echo # Configure Nginx if needed
echo if [ ! -f /etc/nginx/sites-available/email-app ]; then
echo     echo "Configuring Nginx..."
echo     sudo tee /etc/nginx/sites-available/email-app ^> /dev/null ^<^< 'NGINX'
echo server {
echo     listen 80;
echo     server_name _;
echo.
echo     location / {
echo         root /home/emailapp/email-app/dist;
echo         try_files $uri $uri/ /index.html;
echo     }
echo.
echo     location /api {
echo         proxy_pass http://localhost:3001;
echo         proxy_http_version 1.1;
echo         proxy_set_header Upgrade $http_upgrade;
echo         proxy_set_header Connection 'upgrade';
echo         proxy_set_header Host $host;
echo         proxy_cache_bypass $http_upgrade;
echo     }
echo }
echo NGINX
echo.
echo     sudo ln -sf /etc/nginx/sites-available/email-app /etc/nginx/sites-enabled/
echo     sudo nginx -t ^&^& sudo systemctl reload nginx
echo fi
echo.
echo echo "Deployment completed!"
) > deploy-vps-temp.sh

REM Convert to Unix format and upload
echo Converting script to Unix format...
powershell -Command "(Get-Content deploy-vps-temp.sh) -replace '`r`n', '`n' | Set-Content -NoNewline deploy-vps-temp-unix.sh"

REM Upload and execute on VPS
echo Uploading script to VPS...
scp deploy-vps-temp-unix.sh %VPS_USER%@%VPS_HOST%:/tmp/deploy-script.sh
if errorlevel 1 (
    echo [ERROR] Failed to upload script to VPS!
    del deploy-vps-temp.sh
    del deploy-vps-temp-unix.sh
    pause
    exit /b 1
)

echo Executing deployment on VPS...
ssh %VPS_USER%@%VPS_HOST% "chmod +x /tmp/deploy-script.sh && bash /tmp/deploy-script.sh && rm /tmp/deploy-script.sh"
if errorlevel 1 (
    echo [ERROR] Deployment on VPS failed!
    del deploy-vps-temp.sh
    del deploy-vps-temp-unix.sh
    pause
    exit /b 1
)

REM Cleanup
del deploy-vps-temp.sh
del deploy-vps-temp-unix.sh

echo.
echo ===================================
echo   Deployment Complete!
echo ===================================
echo.
echo Your app is available at: http://%VPS_HOST%
echo.
echo Useful commands on VPS:
echo - Check status: pm2 status
echo - View logs: pm2 logs email-app
echo - Restart app: pm2 restart email-app
echo.

pause