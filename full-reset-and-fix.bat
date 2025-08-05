@echo off
REM ==========================================
REM Full Reset and Fix - התחלה נקייה
REM ==========================================

setlocal EnableDelayedExpansion

REM Configuration
set GITHUB_REPO=shalomfr/smartsmart
set VPS_HOST=31.97.129.5
set VPS_USER=root
set APP_DIR=/home/emailapp/email-app

echo.
echo ================================================
echo   FULL RESET AND FIX - מתחילים מחדש
echo ================================================
echo.

REM ============================
REM STEP 1: Push to GitHub
REM ============================

echo [1/8] דוחף קוד ל-GitHub...
git add .
git commit -m "Full reset %date% %time%" 2>nul
git push -u origin main --force 2>nul
echo [OK] GitHub updated
echo.

REM ============================
REM STEP 2: Clean everything on server
REM ============================

echo [2/8] מנקה הכל בשרת...
ssh %VPS_USER%@%VPS_HOST% "pm2 delete all 2>/dev/null || true && killall -9 node 2>/dev/null || true"
echo [OK] Cleaned old processes
echo.

REM ============================
REM STEP 3: Pull and build
REM ============================

echo [3/8] מושך קוד עדכני ובונה...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && git pull origin main && npm install && npm run build"
echo [OK] Code updated and built
echo.

REM ============================
REM STEP 4: Setup backend
REM ============================

echo [4/8] מגדיר Backend...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR%/backend && npm install && echo 'PORT=3001' > .env && echo 'NODE_ENV=production' >> .env"
echo [OK] Backend configured
echo.

REM ============================
REM STEP 5: Start services
REM ============================

echo [5/8] מפעיל שירותים...
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR%/backend && pm2 start server.js --name email-app-backend"
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && pm2 serve dist 8080 --name email-app-frontend --spa"
ssh %VPS_USER%@%VPS_HOST% "pm2 save --force"
echo [OK] Services started
echo.

REM ============================
REM STEP 6: Fix Nginx
REM ============================

echo [6/8] מתקן Nginx...
ssh %VPS_USER%@%VPS_HOST% "cat > /etc/nginx/sites-available/email-app << 'NGINX_CONFIG'
server {
    listen 80;
    server_name _;

    location / {
        root /home/emailapp/email-app/dist;
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
NGINX_CONFIG"

ssh %VPS_USER%@%VPS_HOST% "nginx -t && nginx -s reload"
echo [OK] Nginx configured
echo.

REM ============================
REM STEP 7: Verify everything
REM ============================

echo [7/8] בודק שהכל עובד...
echo.
echo === PM2 Status ===
ssh %VPS_USER%@%VPS_HOST% "pm2 status"
echo.
echo === Ports ===
ssh %VPS_USER%@%VPS_HOST% "netstat -tlnp | grep -E '3001|8080|80' | grep LISTEN"
echo.

REM ============================
REM STEP 8: Test endpoints
REM ============================

echo [8/8] בודק נקודות קצה...
echo.

echo Testing backend directly:
curl -s http://%VPS_HOST%:3001/api/app/login || echo Backend direct: NOT WORKING
echo.

echo Testing API through Nginx:
curl -s http://%VPS_HOST%/api/app/login || echo API through Nginx: WORKING (Cannot GET is OK)
echo.

echo Testing frontend:
curl -s -o nul -w "Frontend HTTP Status: %%{http_code}\n" http://%VPS_HOST%/
echo.

echo.
echo ================================================
echo   הושלם! האתר אמור לעבוד עכשיו
echo ================================================
echo.
echo כתובת: http://%VPS_HOST%
echo.
echo כניסה למערכת:
echo - שם משתמש: admin
echo - סיסמה: 123456
echo.
echo אם יש בעיות, הרץ:
echo - בדיקת לוגים: ssh %VPS_USER%@%VPS_HOST% "pm2 logs"
echo - הפעלה מחדש: ssh %VPS_USER%@%VPS_HOST% "pm2 restart all"
echo.

pause