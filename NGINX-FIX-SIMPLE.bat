@echo off
echo ===== תיקון Nginx פשוט =====
echo.

echo מתקן את Nginx...
ssh root@31.97.129.5 "echo 'server { listen 80; server_name _; location / { root /home/emailapp/email-app/dist; try_files $uri $uri/ /index.html; } location /api { proxy_pass http://127.0.0.1:3001; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection ''upgrade''; proxy_set_header Host $host; proxy_cache_bypass $http_upgrade; } }' > /etc/nginx/sites-available/email-app && nginx -t && systemctl restart nginx"

echo.
echo בודק סטטוס...
ssh root@31.97.129.5 "systemctl status nginx | grep Active && netstat -tlnp | grep :80"

echo.
echo בודק אתר...
timeout /t 3 /nobreak >nul
curl -s -o nul -w "Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo גש ל: http://31.97.129.5
echo.
pause