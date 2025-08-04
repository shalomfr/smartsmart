@echo off
chcp 65001 > nul
echo ==========================================================
echo    🚀 התקנה מחדש ומלאה של השרת
echo ==========================================================
echo סקריפט זה ימחק את האפליקציה הנוכחית בשרת
echo ויתקין אותה מחדש מאפס.
echo.
pause

echo.
echo [1/3] יוצר את סקריפט ההתקנה...

(
echo #!/bin/bash
echo set -e
echo.
echo APP_DIR="/home/emailapp/email-app"
echo GIT_REPO_URL="https://github.com/shalomfr/smartsmart.git"
echo BACKEND_PM2_NAME="email-app-backend"
echo FRONTEND_PM2_NAME="email-app-frontend"
echo.
echo echo "--- [1/7] Stopping and deleting old PM2 processes..."
echo pm2 stop $BACKEND_PM2_NAME ^> /dev/null 2^>^&1 ^|^| true
echo pm2 delete $BACKEND_PM2_NAME ^> /dev/null 2^>^&1 ^|^| true
echo pm2 stop $FRONTEND_PM2_NAME ^> /dev/null 2^>^&1 ^|^| true
echo pm2 delete $FRONTEND_PM2_NAME ^> /dev/null 2^>^&1 ^|^| true
echo.
echo echo "--- [2/7] Removing old application directory: $APP_DIR..."
echo rm -rf $APP_DIR
echo.
echo echo "--- [3/7] Cloning fresh repository from GitHub..."
echo git clone $GIT_REPO_URL $APP_DIR
echo.
echo echo "--- [4/7] Installing root (frontend) dependencies..."
echo cd $APP_DIR
echo npm install
echo.
echo echo "--- [5/7] Installing backend dependencies..."
echo cd $APP_DIR/backend
echo npm install
echo.
echo echo "--- [6/7] Building frontend application..."
echo cd $APP_DIR
echo npm run build
echo.
echo echo "--- [7/7] Starting applications with PM2..."
echo cd $APP_DIR/backend
echo pm2 start server.js --name $BACKEND_PM2_NAME
echo.
echo cd $APP_DIR
echo pm2 serve dist 8080 --name $FRONTEND_PM2_NAME --spa
echo.
echo echo "--- Redeployment complete. Final PM2 status: ---"
echo pm2 status
echo.
echo echo "--- Saving PM2 process list..."
echo pm2 save --force
echo.
echo echo "--- Done! ---"
) > redeploy-vps.sh

echo.
echo [2/3] מעלה את הסקריפט לשרת...
scp redeploy-vps.sh root@31.97.129.5:~/redeploy.sh

echo.
echo [3/3] מריץ את הסקריפט בשרת...
ssh root@31.97.129.5 "chmod +x ~/redeploy.sh && ~/redeploy.sh"

echo.
del redeploy-vps.sh
echo.
echo ==========================================================
echo    ✅ סיום! השרת תוקן והותקן מחדש.
echo ==========================================================
echo.
pause
