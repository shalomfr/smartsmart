@echo off
echo ===== תיקון מיידי של האתר =====
echo.

echo [1] בודק מה הבעיה...
echo ===========================
ssh root@31.97.129.5 "echo 'PM2:' && pm2 list && echo && echo 'Nginx:' && systemctl status nginx | grep Active && echo && echo 'Ports:' && netstat -tlnp | grep -E ':80|:3001|:8080' | grep LISTEN"

echo.
echo [2] מתקן הכל...
echo ================

REM Kill everything and start fresh
ssh root@31.97.129.5 "pm2 kill && systemctl stop nginx"

REM Start backend
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && echo 'PORT=3001' > .env && pm2 start server.js --name backend"

REM Start frontend
ssh root@31.97.129.5 "cd /home/emailapp/email-app && pm2 serve dist 8080 --name frontend --spa"

REM Save PM2
ssh root@31.97.129.5 "pm2 save --force"

REM Fix and start Nginx
ssh root@31.97.129.5 "echo 'server { listen 80; server_name _; location / { root /home/emailapp/email-app/dist; try_files \$uri \$uri/ /index.html; } location /api { proxy_pass http://127.0.0.1:3001; proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \"upgrade\"; proxy_set_header Host \$host; proxy_cache_bypass \$http_upgrade; } }' > /etc/nginx/sites-available/email-app"

ssh root@31.97.129.5 "ln -sf /etc/nginx/sites-available/email-app /etc/nginx/sites-enabled/ && rm -f /etc/nginx/sites-enabled/default"

ssh root@31.97.129.5 "nginx -t && systemctl start nginx && systemctl enable nginx"

echo.
echo [3] בדיקה סופית...
echo ===================
timeout /t 3 /nobreak >nul

echo.
echo PM2 Status:
ssh root@31.97.129.5 "pm2 list"

echo.
echo Website Status:
curl -s -o nul -w "HTTP: %%{http_code}\n" http://31.97.129.5/

echo.
echo ===== הושלם! =====
echo.
echo נסה עכשיו: http://31.97.129.5
echo משתמש: admin
echo סיסמה: 123456
echo.
pause