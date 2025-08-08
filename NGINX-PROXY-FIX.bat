@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *        הגדרת Nginx Proxy ל-API                  *
echo ****************************************************
echo.

echo [1] יוצר קובץ הגדרות nginx...
echo ==============================
(
echo server {
echo     listen 8082;
echo     server_name _;
echo.
echo     location / {
echo         root /home/emailapp/site2/dist;
echo         try_files $uri $uri/ /index.html;
echo     }
echo.
echo     location /api {
echo         proxy_pass http://localhost:4000;
echo         proxy_http_version 1.1;
echo         proxy_set_header Upgrade $http_upgrade;
echo         proxy_set_header Connection 'upgrade';
echo         proxy_set_header Host $host;
echo         proxy_cache_bypass $http_upgrade;
echo     }
echo }
) > site2-nginx.conf

echo.
echo [2] מעלה לשרת...
echo =================
scp site2-nginx.conf root@31.97.129.5:/tmp/

echo.
echo [3] מתקין בשרת...
echo ==================
ssh root@31.97.129.5 "cp /tmp/site2-nginx.conf /etc/nginx/sites-available/site2"
ssh root@31.97.129.5 "ln -sf /etc/nginx/sites-available/site2 /etc/nginx/sites-enabled/"
ssh root@31.97.129.5 "nginx -t && systemctl reload nginx"

echo.
echo [4] עוצר את pm2 serve ומשתמש ב-nginx...
echo ========================================
ssh root@31.97.129.5 "pm2 delete site2-frontend"

echo.
echo ****************************************************
echo *          עכשיו נסה להתחבר!                      *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8082
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
pause