@echo off
echo ================================================
echo      מוסיף את site2 ל-VPS
echo ================================================
echo.
echo פרטי האתר:
echo - שם: site2
echo - כתובת: http://31.97.129.5:8081
echo - Backend Port: 4000
echo - Frontend Port: 9000
echo.
echo לחץ Enter להתחיל או Ctrl+C לביטול...
pause >nul

echo.
echo [1] מתחבר לשרת ומתקין...
echo ================================

ssh root@31.97.129.5 "bash -c '
echo \"========== מתקין את site2 ==========\"
echo

# יוצר תיקייה חדשה
echo \"[1] יוצר תיקייה לאתר החדש...\"
mkdir -p /home/emailapp/site2
cd /home/emailapp/site2

# מעתיק את הקוד
echo \"[2] מעתיק את הקוד מהאתר הקיים...\"
cp -r /home/emailapp/email-app/* /home/emailapp/site2/ 2>/dev/null
if [ $? -ne 0 ]; then
    echo \"   מושך מ-GitHub...\"
    git clone https://github.com/shalomfr/smartsmart.git .
fi

# מתקין dependencies
echo \"[3] מתקין חבילות Frontend...\"
npm install --force

# בונה את האתר
echo \"[4] בונה את האתר...\"
npm run build

# מגדיר את הבקאנד
echo \"[5] מגדיר את הבקאנד על פורט 4000...\"
cd backend
echo \"PORT=4000\" > .env
echo \"NODE_ENV=production\" >> .env
npm install

# עוצר תהליכים ישנים אם יש
echo \"[6] מנקה תהליכים ישנים...\"
pm2 delete site2-backend 2>/dev/null
pm2 delete site2-frontend 2>/dev/null

# מפעיל עם PM2
echo \"[7] מפעיל את השירותים...\"
pm2 start server.js --name site2-backend
cd ..
pm2 serve dist 9000 --name site2-frontend --spa
pm2 save

# מגדיר Nginx
echo \"[8] מגדיר את Nginx...\"
cat > /etc/nginx/sites-available/site2 << EOL
server {
    listen 8081;
    server_name _;
    
    location / {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \\\$host;
        proxy_cache_bypass \\\$http_upgrade;
    }
    
    location /api {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \\\$host;
        proxy_cache_bypass \\\$http_upgrade;
    }
}
EOL

# מפעיל את האתר ב-Nginx
ln -sf /etc/nginx/sites-available/site2 /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# פותח את הפורטים בחומת האש
echo \"[9] פותח פורטים בחומת האש...\"
ufw allow 4000/tcp
ufw allow 9000/tcp
ufw allow 8081/tcp
ufw reload

echo
echo \"========== בדיקות סופיות ==========\"
echo

echo \"PM2 Status:\"
pm2 list | grep site2

echo
echo \"Nginx Test:\"
nginx -t

echo
echo \"Port Check:\"
netstat -tlnp | grep -E \"4000|9000|8081\"

echo
echo \"Quick Test:\"
curl -s -o /dev/null -w \"Frontend (9000): %%{http_code}\\n\" http://localhost:9000
curl -s -o /dev/null -w \"Backend (4000): %%{http_code}\\n\" http://localhost:4000/api
curl -s -o /dev/null -w \"Nginx (8081): %%{http_code}\\n\" http://localhost:8081

echo
echo \"========== סיום התקנה ==========\"
echo \"site2 מותקן ופועל!\"
echo
echo \"גישה:\"
echo \"- אתר ראשי: http://31.97.129.5:8081\"
echo \"- Backend ישיר: http://31.97.129.5:4000\"
echo \"- Frontend ישיר: http://31.97.129.5:9000\"
echo
echo \"משתמש לבדיקה:\"
echo \"- Username: admin\"
echo \"- Password: 123456\"
'"

echo.
echo ================================================
echo   ✅ site2 הותקן בהצלחה!
echo ================================================
echo.
echo 🌐 כתובות גישה:
echo.
echo   אתר ראשי: http://31.97.129.5:8081
echo   Backend API: http://31.97.129.5:4000/api
echo   Frontend: http://31.97.129.5:9000
echo.
echo 🔑 פרטי התחברות:
echo   Username: admin
echo   Password: 123456
echo.
echo 📊 לבדיקת סטטוס:
echo   ssh root@31.97.129.5 "pm2 list"
echo.
pause