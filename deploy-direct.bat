@echo off
REM ==========================================
REM Direct Deploy - Without temp files
REM ==========================================

setlocal EnableDelayedExpansion

REM Configuration
set GITHUB_REPO=shalomfr/smartsmart
set VPS_HOST=31.97.129.5
set VPS_USER=root
set APP_DIR=/home/emailapp/email-app

echo.
echo ===================================
echo   Direct Deployment to VPS
echo ===================================
echo.

REM Part 1: Push to GitHub
echo [1/2] Pushing to GitHub...
git add .
git commit -m "Deploy: %date% %time%" 2>nul
git push -u origin main --force

if errorlevel 1 (
    echo [WARNING] Git push might have failed, continuing anyway...
)

REM Part 2: Deploy directly on VPS
echo.
echo [2/2] Deploying to VPS...

REM Execute commands directly on VPS
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && git pull origin main && npm install && npm run build && cd backend && npm install && [ ! -f .env ] && echo 'PORT=3001' > .env || true && pm2 delete email-app-backend 2>/dev/null || true && pm2 start server.js --name email-app-backend && cd .. && pm2 delete email-app-frontend 2>/dev/null || true && pm2 serve dist 8080 --name email-app-frontend --spa && pm2 save"

if errorlevel 1 (
    echo [ERROR] Deployment failed!
    echo.
    echo Trying alternative deployment method...
    ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && git pull && npm install && npm run build && cd backend && npm install && pm2 restart all"
)

echo.
echo ===================================
echo   Checking deployment status...
echo ===================================
echo.

ssh %VPS_USER%@%VPS_HOST% "pm2 status"

echo.
echo ===================================
echo   Deployment Complete!
echo ===================================
echo.
echo Your app is available at: http://%VPS_HOST%
echo.

pause