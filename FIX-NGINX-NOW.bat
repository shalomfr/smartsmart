@echo off
echo ===== מתקן את Nginx =====
echo.

echo [1] עוצר את Nginx...
ssh root@31.97.129.5 "systemctl stop nginx"

echo [2] בודק קונפיגורציה...
ssh root@31.97.129.5 "nginx -t"

echo [3] מתקן את הקובץ...
ssh root@31.97.129.5 "cat > /etc/nginx/sites-available/email-app << 'EOF'
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
    }
}
EOF"

echo [4] מוחק default site...
ssh root@31.97.129.5 "rm -f /etc/nginx/sites-enabled/default"

echo [5] מפעיל מחדש...
ssh root@31.97.129.5 "nginx -t && systemctl start nginx && systemctl enable nginx"

echo [6] בודק סטטוס...
ssh root@31.97.129.5 "systemctl status nginx | grep Active"

echo [7] בודק פורטים...
ssh root@31.97.129.5 "netstat -tlnp | grep :80"

echo.
echo ===== בדיקת גישה =====
timeout /t 3 /nobreak >nul
curl -s -o nul -w "Website Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo נסה עכשיו: http://31.97.129.5
echo.
pause