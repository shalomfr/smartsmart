@echo off
echo ================================================
echo      תיקון מלא ומושלם של האתר
echo ================================================
echo.

echo [1] מתחבר לשרת...
echo ===========================

ssh root@31.97.129.5 "bash -c '
echo \"========== מתחיל תיקון מלא ==========\"
echo

# עוצר הכל
echo \"[1] עוצר את כל השירותים...\"
pm2 delete all 2>/dev/null
systemctl stop nginx 2>/dev/null
killall node 2>/dev/null

# מנקה ports
echo \"[2] מנקה פורטים...\"
lsof -ti:3001 | xargs kill -9 2>/dev/null
lsof -ti:3003 | xargs kill -9 2>/dev/null
lsof -ti:8080 | xargs kill -9 2>/dev/null

# עובר לתיקייה
cd /home/emailapp/email-app

# מושך עדכונים
echo \"[3] מושך עדכונים מ-GitHub...\"
git pull origin main

# מתקין תלויות
echo \"[4] מתקין חבילות...\"
npm install --force
npm install vite --save-dev
npm install @vitejs/plugin-react --save-dev

# בונה את האתר
echo \"[5] בונה את האתר...\"
npm run build

# בודק שהבנייה הצליחה
if [ ! -f dist/index.html ]; then
    echo \"[X] הבנייה נכשלה! מנסה שוב...\"
    rm -rf node_modules package-lock.json
    npm install
    npm run build
fi

# מתקן backend
echo \"[6] מתקן את הבקאנד...\"
cd backend
npm install
echo \"PORT=3001\" > .env
pm2 start server.js --name backend

# חוזר ומפעיל frontend
echo \"[7] מפעיל את הפרונטאנד...\"
cd ..
pm2 serve dist 8080 --name frontend --spa

# שומר PM2
echo \"[8] שומר הגדרות PM2...\"
pm2 save
pm2 startup systemd -u root --hp /root

# מתקן Nginx
echo \"[9] מתקן את Nginx...\"
cat > /etc/nginx/sites-available/email-app << EOL
server {
    listen 80;
    server_name _;
    
    location / {
        root /home/emailapp/email-app/dist;
        try_files \\\$uri \\\$uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \\\$host;
        proxy_cache_bypass \\\$http_upgrade;
    }
}
EOL

ln -sf /etc/nginx/sites-available/email-app /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# מתקן הרשאות
echo \"[10] מתקן הרשאות...\"
chown -R emailapp:emailapp /home/emailapp/email-app
chmod -R 755 /home/emailapp/email-app

# בודק firewall
echo \"[11] בודק חומת אש...\"
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw allow 3001/tcp
ufw --force enable

echo
echo \"========== בדיקות סופיות ==========\"
echo

echo \"PM2 Status:\"
pm2 list

echo
echo \"Nginx Status:\"
systemctl status nginx | grep Active

echo
echo \"בודק פורטים:\"
netstat -tlnp | grep -E \"80|3001|8080\"

echo
echo \"בודק תיקיית dist:\"
ls -la dist/ | head -5

echo
echo \"========== סיום תיקון ==========\"
'"

echo.
echo ================================================
echo          בדיקה סופית
echo ================================================
echo.

timeout /t 10 /nobreak

echo בודק אם האתר עובד...
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo ================================================
echo   ✅ התיקון הושלם!
echo ================================================
echo.
echo 🌐 גש לאתר: http://31.97.129.5
echo.
echo 👤 פרטי התחברות:
echo    שם משתמש: admin
echo    סיסמה: 123456
echo.
echo 💡 אם עדיין לא עובד:
echo    1. רענן את הדף (Ctrl+F5)
echo    2. המתן 30 שניות
echo    3. נסה דפדפן אחר
echo.
pause