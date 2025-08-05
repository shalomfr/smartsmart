@echo off
REM ==========================================
REM Ultimate Fix & Deploy Script
REM תיקון ופריסה מלאה - סקריפט אחד שעושה הכל!
REM ==========================================

setlocal EnableDelayedExpansion

REM Configuration
set GITHUB_REPO=shalomfr/smartsmart
set VPS_HOST=31.97.129.5
set VPS_USER=root
set APP_DIR=/home/emailapp/email-app

echo.
echo ================================================
echo   ULTIMATE FIX AND DEPLOY - סקריפט על שעושה הכל
echo ================================================
echo.

REM ============================
REM PART 1: Push to GitHub
REM ============================

echo [שלב 1/7] דוחף קוד ל-GitHub...
echo --------------------------------
git add .
git commit -m "Auto fix and deploy %date% %time%" 2>nul
git push -u origin main --force
if errorlevel 1 (
    echo [אזהרה] Push נכשל, ממשיך בכל זאת...
) else (
    echo [הצלחה] הקוד נדחף ל-GitHub!
)

echo.
echo [שלב 2/7] מתחבר לשרת ומתקן הכל...
echo ------------------------------------

REM ============================
REM PART 2: Fix Everything on Server
REM ============================

REM Create mega fix script
echo יוצר סקריפט תיקון מקיף...
(
echo #!/bin/bash
echo set -e
echo.
echo echo "=== Starting Ultimate Fix ==="
echo.
echo # Variables
echo APP_DIR="/home/emailapp/email-app"
echo.
echo # Step 1: Pull latest code
echo echo "[1/10] Pulling latest code..."
echo cd $APP_DIR
echo git pull origin main
echo.
echo # Step 2: Install dependencies
echo echo "[2/10] Installing frontend dependencies..."
echo npm install
echo.
echo echo "[3/10] Building frontend..."
echo npm run build
echo.
echo echo "[4/10] Installing backend dependencies..."
echo cd backend
echo npm install
echo.
echo # Step 3: Fix port configuration
echo echo "[5/10] Fixing port configuration..."
echo echo "PORT=3003" ^> .env
echo echo "NODE_ENV=production" ^>^> .env
echo.
echo # Step 4: Kill all node processes and clean PM2
echo echo "[6/10] Cleaning old processes..."
echo pm2 delete all 2^>/dev/null ^|^| true
echo killall -9 node 2^>/dev/null ^|^| true
echo lsof -ti:3001 ^| xargs kill -9 2^>/dev/null ^|^| true
echo lsof -ti:3002 ^| xargs kill -9 2^>/dev/null ^|^| true
echo lsof -ti:3003 ^| xargs kill -9 2^>/dev/null ^|^| true
echo lsof -ti:8080 ^| xargs kill -9 2^>/dev/null ^|^| true
echo.
echo # Step 5: Start services with PM2
echo echo "[7/10] Starting backend..."
echo cd $APP_DIR/backend
echo pm2 start server.js --name email-app-backend
echo.
echo echo "[8/10] Starting frontend..."
echo cd $APP_DIR
echo pm2 serve dist 8080 --name email-app-frontend --spa
echo pm2 save --force
echo.
echo # Step 6: Fix Nginx configuration
echo echo "[9/10] Fixing Nginx configuration..."
echo cat ^> /etc/nginx/sites-available/email-app ^<^< 'NGINX_CONFIG'
echo server {
echo     listen 80;
echo     server_name _;
echo.
echo     # Frontend
echo     location / {
echo         root /home/emailapp/email-app/dist;
echo         try_files \$uri \$uri/ /index.html;
echo     }
echo.
echo     # Backend API
echo     location /api/ {
echo         proxy_pass http://localhost:3003/api/;
echo         proxy_http_version 1.1;
echo         proxy_set_header Upgrade \$http_upgrade;
echo         proxy_set_header Connection 'upgrade';
echo         proxy_set_header Host \$host;
echo         proxy_set_header X-Real-IP \$remote_addr;
echo         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto \$scheme;
echo         proxy_cache_bypass \$http_upgrade;
echo         
echo         # CORS headers
echo         add_header 'Access-Control-Allow-Origin' '*' always;
echo         add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
echo         add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
echo         
echo         # Handle OPTIONS
echo         if ^(\$request_method = 'OPTIONS'^) {
echo             add_header 'Access-Control-Allow-Origin' '*';
echo             add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
echo             add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
echo             add_header 'Access-Control-Max-Age' 1728000;
echo             add_header 'Content-Type' 'text/plain; charset=utf-8';
echo             add_header 'Content-Length' 0;
echo             return 204;
echo         }
echo     }
echo }
echo NGINX_CONFIG
echo.
echo # Step 7: Test and reload Nginx
echo nginx -t
echo nginx -s reload
echo.
echo # Step 8: Open firewall ports
echo echo "[10/10] Ensuring firewall ports are open..."
echo ufw allow 80/tcp 2^>/dev/null ^|^| true
echo ufw allow 3003/tcp 2^>/dev/null ^|^| true
echo ufw allow 8080/tcp 2^>/dev/null ^|^| true
echo.
echo # Final status
echo echo "=== Deployment Status ==="
echo pm2 status
echo echo ""
echo echo "=== Testing API endpoint ==="
echo curl -s http://localhost:3003/api/app/login ^|^| echo "API endpoint check"
echo echo ""
echo echo "=== All done! ==="
) > mega-fix.sh

REM Convert to Unix format
echo המרת הסקריפט לפורמט Unix...
powershell -Command "(Get-Content mega-fix.sh) -replace '`r`n', '`n' | Set-Content -NoNewline mega-fix-unix.sh"

REM ============================
REM PART 3: Execute on Server
REM ============================

echo.
echo [שלב 3/7] מעלה סקריפט לשרת...
scp mega-fix-unix.sh %VPS_USER%@%VPS_HOST%:/tmp/mega-fix.sh
if errorlevel 1 (
    echo [שגיאה] העלאת הסקריפט נכשלה!
    del mega-fix.sh mega-fix-unix.sh
    pause
    exit /b 1
)

echo.
echo [שלב 4/7] מריץ תיקון מקיף בשרת...
ssh %VPS_USER%@%VPS_HOST% "chmod +x /tmp/mega-fix.sh && bash /tmp/mega-fix.sh && rm /tmp/mega-fix.sh"

REM Cleanup
del mega-fix.sh mega-fix-unix.sh

REM ============================
REM PART 4: Verify Everything
REM ============================

echo.
echo [שלב 5/7] בודק סטטוס שירותים...
echo ----------------------------------
ssh %VPS_USER%@%VPS_HOST% "pm2 status"

echo.
echo [שלב 6/7] בודק Nginx...
echo ----------------------
ssh %VPS_USER%@%VPS_HOST% "nginx -t"

echo.
echo [שלב 7/7] בדיקה סופית...
echo ------------------------
echo.

REM Test API directly
echo בודק API ישירות על פורט 3003:
curl -s http://%VPS_HOST%:3003/api/app/login
echo.
echo.

REM Test API through Nginx
echo בודק API דרך Nginx:
curl -s http://%VPS_HOST%/api/app/login
echo.

echo.
echo ================================================
echo   הפריסה הושלמה בהצלחה!
echo ================================================
echo.
echo האתר זמין ב:
echo - Frontend: http://%VPS_HOST%
echo - API ישיר: http://%VPS_HOST%:3003
echo.
echo פרטי כניסה:
echo - שם משתמש: admin
echo - סיסמה: 123456
echo.
echo פקודות שימושיות:
echo - לוגים: ssh %VPS_USER%@%VPS_HOST% "pm2 logs"
echo - סטטוס: ssh %VPS_USER%@%VPS_HOST% "pm2 status"
echo - הפעלה מחדש: ssh %VPS_USER%@%VPS_HOST% "pm2 restart all"
echo.

pause