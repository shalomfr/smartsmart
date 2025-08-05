@echo off
echo ===== תיקון שגיאת 500 =====
echo.

echo [1] בודק מה גורם לשגיאה...
ssh root@31.97.129.5 "tail -20 /var/log/nginx/error.log"

echo.
echo [2] בודק אם השירותים רצים...
ssh root@31.97.129.5 "pm2 list && netstat -tlnp | grep -E ':3001|:8080'"

echo.
echo [3] מתקן את הבעיה...

REM תיקון 1: בונה מחדש את dist
ssh root@31.97.129.5 "cd /home/emailapp/email-app && [ ! -d dist ] && npm run build || echo 'dist exists'"

REM תיקון 2: מוודא ש-backend רץ על 3001
ssh root@31.97.129.5 "pm2 delete backend 2>/dev/null; cd /home/emailapp/email-app/backend && echo 'PORT=3001' > .env && pm2 start server.js --name backend"

REM תיקון 3: מוודא ש-frontend רץ
ssh root@31.97.129.5 "pm2 delete frontend 2>/dev/null; cd /home/emailapp/email-app && pm2 serve dist 8080 --name frontend --spa"

REM תיקון 4: Nginx config נכון
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
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF"

REM תיקון 5: הפעלה מחדש
ssh root@31.97.129.5 "nginx -t && systemctl reload nginx && pm2 save"

echo.
echo [4] בדיקה סופית...
timeout /t 3 /nobreak >nul
curl -I http://31.97.129.5/

echo.
echo ===== הושלם! =====
echo נסה: http://31.97.129.5
echo.
pause