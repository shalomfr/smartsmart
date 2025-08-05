@echo off
echo ===== מתקן את בעיית Nginx =====
echo.

echo [1] בודק אם יש קבצי dist...
ssh root@31.97.129.5 "ls -la /home/emailapp/email-app/dist/"

echo.
echo [2] אם אין, בונה מחדש...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && [ ! -f dist/index.html ] && npm run build || echo 'dist exists'"

echo.
echo [3] מתקן את Nginx לתיקייה הנכונה...
ssh root@31.97.129.5 "cat > /etc/nginx/sites-available/email-app << 'EOF'
server {
    listen 80;
    server_name _;
    root /home/emailapp/email-app/dist;
    index index.html;
    
    location / {
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

echo.
echo [4] בודק ומפעיל מחדש...
ssh root@31.97.129.5 "nginx -t && systemctl reload nginx"

echo.
echo [5] מתקן את פורט הבקאנד...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && echo 'PORT=3001' > .env && pm2 delete backend && pm2 start server.js --name backend"

echo.
echo [6] בדיקה סופית...
timeout /t 3 /nobreak >nul
curl -s -o nul -w "Website Status: %%{http_code}\n" http://31.97.129.5/
curl -s http://31.97.129.5/api/app/login && echo API works!

echo.
echo ===== הושלם! =====
echo גש ל: http://31.97.129.5
echo.
pause