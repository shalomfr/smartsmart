@echo off
REM ==========================================
REM Safe Deploy - With proper line endings
REM ==========================================

setlocal EnableDelayedExpansion

REM Configuration
set GITHUB_REPO=shalomfr/smartsmart
set VPS_HOST=31.97.129.5
set VPS_USER=root
set APP_DIR=/home/emailapp/email-app

echo.
echo ===================================
echo   Safe Deployment Script
echo ===================================
echo.

REM Part 1: Push to GitHub
echo [Step 1] Pushing code to GitHub...
echo.
git add .
if errorlevel 1 goto :error_git

git commit -m "Deploy: %date% %time%"
if errorlevel 1 (
    echo No changes to commit, continuing...
)

git push -u origin main
if errorlevel 1 (
    echo Trying force push...
    git push -u origin main --force
    if errorlevel 1 goto :error_git
)

echo.
echo [SUCCESS] Code pushed to GitHub!
echo.

REM Part 2: Create deployment commands
echo [Step 2] Preparing deployment commands...

REM Use SSH to run commands directly
echo [Step 3] Deploying to VPS...
echo.

REM Install dos2unix if not available
ssh %VPS_USER%@%VPS_HOST% "which dos2unix > /dev/null 2>&1 || apt-get install -y dos2unix"

REM Run deployment commands one by one
echo - Navigating to app directory...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% || exit 1"

echo - Pulling latest code...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && git pull origin main"

echo - Installing frontend dependencies...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && npm install"

echo - Building frontend...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && npm run build"

echo - Installing backend dependencies...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR%/backend && npm install"

echo - Creating .env file if needed...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR%/backend && [ ! -f .env ] && echo 'PORT=3001' > .env && echo 'NODE_ENV=production' >> .env || echo '.env already exists'"

echo - Restarting backend...
ssh %VPS_USER%@%VPS_HOST% "pm2 delete email-app-backend 2>/dev/null; cd %APP_DIR%/backend && pm2 start server.js --name email-app-backend"

echo - Restarting frontend...
ssh %VPS_USER%@%VPS_HOST% "pm2 delete email-app-frontend 2>/dev/null; cd %APP_DIR% && pm2 serve dist 8080 --name email-app-frontend --spa"

echo - Saving PM2 configuration...
ssh %VPS_USER%@%VPS_HOST% "pm2 save"

echo.
echo [Step 4] Verifying deployment...
ssh %VPS_USER%@%VPS_HOST% "pm2 status"

echo.
echo ===================================
echo   Deployment Complete!
echo ===================================
echo.
echo Your app is available at: http://%VPS_HOST%
echo.
echo To check logs: ssh %VPS_USER%@%VPS_HOST% "pm2 logs"
echo.
pause
exit /b 0

:error_git
echo.
echo [ERROR] Git operation failed!
echo Please check your git configuration and try again.
echo.
pause
exit /b 1