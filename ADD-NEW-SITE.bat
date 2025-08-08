@echo off
echo ================================================
echo      הוספת אתר חדש ל-VPS קיים
echo ================================================
echo.

set /p SITE_NAME="הכנס שם לאתר החדש (למשל: site2): "
set /p DOMAIN="הכנס דומיין או כתובת IP (למשל: site2.example.com או IP:8081): "
set /p BACKEND_PORT="הכנס פורט לבקאנד (למשל: 3002): "
set /p FRONTEND_PORT="הכנס פורט לפרונטאנד (למשל: 8081): "

echo.
echo ================================================
echo  מתקין את האתר החדש: %SITE_NAME%
echo  דומיין/כתובת: %DOMAIN%
echo  Backend Port: %BACKEND_PORT%
echo  Frontend Port: %FRONTEND_PORT%
echo ================================================
echo.

ssh root@31.97.129.5 "bash -c '
echo \"========== מוסיף אתר חדש: %SITE_NAME% ==========\"
echo

# יוצר תיקייה חדשה לאתר
echo \"[1] יוצר תיקייה לאתר החדש...\"
mkdir -p /home/emailapp/%SITE_NAME%
cd /home/emailapp/%SITE_NAME%

# מעתיק את הקוד מהאתר הקיים (או משוכפל מ-GitHub)
echo \"[2] מעתיק את הקוד...\"
cp -r /home/emailapp/email-app/* /home/emailapp/%SITE_NAME%/ 2>/dev/null || git clone https://github.com/shalomfr/smartsmart.git .

# מתקין dependencies
echo \"[3] מתקין חבילות...\"
npm install

# בונה את האתר
echo \"[4] בונה את האתר...\"
npm run build

# מגדיר את הבקאנד על פורט חדש
echo \"[5] מגדיר את הבקאנד...\"
cd backend
echo \"PORT=%BACKEND_PORT%\" > .env
npm install

# מפעיל עם PM2
echo \"[6] מפעיל את השירותים...\"
pm2 start server.js --name %SITE_NAME%-backend
cd ..
pm2 serve dist %FRONTEND_PORT% --name %SITE_NAME%-frontend --spa
pm2 save

# מגדיר Nginx
echo \"[7] מגדיר את Nginx...\"
cat > /etc/nginx/sites-available/%SITE_NAME% << EOL
server {
    listen 80;
    server_name %DOMAIN%;
    
    location / {
        proxy_pass http://localhost:%FRONTEND_PORT%;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \\\$host;
        proxy_cache_bypass \\\$http_upgrade;
    }
    
    location /api {
        proxy_pass http://localhost:%BACKEND_PORT%;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \\\$host;
        proxy_cache_bypass \\\$http_upgrade;
    }
}
EOL

# מפעיל את האתר ב-Nginx
ln -sf /etc/nginx/sites-available/%SITE_NAME% /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# פותח את הפורטים בחומת האש
echo \"[8] פותח פורטים בחומת האש...\"
ufw allow %BACKEND_PORT%/tcp
ufw allow %FRONTEND_PORT%/tcp
ufw reload

echo
echo \"========== סיכום ==========\"
echo \"האתר החדש הותקן בהצלחה!\"
echo
echo \"פרטי גישה:\"
echo \"- כתובת: http://%DOMAIN%\"
echo \"- Backend: http://31.97.129.5:%BACKEND_PORT%\"
echo \"- Frontend: http://31.97.129.5:%FRONTEND_PORT%\"
echo
echo \"PM2 Apps:\"
pm2 list
echo
echo \"========== סיום ==========\"
'"

echo.
echo ================================================
echo   האתר החדש הותקן בהצלחה!
echo ================================================
echo.
echo פרטי גישה:
echo - אתר ראשי: http://%DOMAIN%
echo - Backend ישיר: http://31.97.129.5:%BACKEND_PORT%
echo - Frontend ישיר: http://31.97.129.5:%FRONTEND_PORT%
echo.
echo כדי לראות את כל האתרים הפעילים:
echo   ssh root@31.97.129.5 "pm2 list"
echo.
pause