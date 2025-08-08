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
echo [1] יוצר סקריפט התקנה...
echo ================================

REM יוצר קובץ סקריפט זמני
echo #!/bin/bash > temp-install-site2.sh
echo echo "========== מתקין את site2 ==========" >> temp-install-site2.sh
echo echo "" >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # יוצר תיקייה חדשה >> temp-install-site2.sh
echo echo "[1] יוצר תיקייה לאתר החדש..." >> temp-install-site2.sh
echo mkdir -p /home/emailapp/site2 >> temp-install-site2.sh
echo cd /home/emailapp/site2 >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # מעתיק את הקוד >> temp-install-site2.sh
echo echo "[2] מעתיק את הקוד מהאתר הקיים..." >> temp-install-site2.sh
echo cp -r /home/emailapp/email-app/* /home/emailapp/site2/ 2^>/dev/null >> temp-install-site2.sh
echo if [ $? -ne 0 ]; then >> temp-install-site2.sh
echo     echo "   מושך מ-GitHub..." >> temp-install-site2.sh
echo     git clone https://github.com/shalomfr/smartsmart.git . >> temp-install-site2.sh
echo fi >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # מתקין dependencies >> temp-install-site2.sh
echo echo "[3] מתקין חבילות Frontend..." >> temp-install-site2.sh
echo npm install --force >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # בונה את האתר >> temp-install-site2.sh
echo echo "[4] בונה את האתר..." >> temp-install-site2.sh
echo npm run build >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # מגדיר את הבקאנד >> temp-install-site2.sh
echo echo "[5] מגדיר את הבקאנד על פורט 4000..." >> temp-install-site2.sh
echo cd backend >> temp-install-site2.sh
echo echo "PORT=4000" ^> .env >> temp-install-site2.sh
echo echo "NODE_ENV=production" ^>^> .env >> temp-install-site2.sh
echo npm install >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # עוצר תהליכים ישנים >> temp-install-site2.sh
echo echo "[6] מנקה תהליכים ישנים..." >> temp-install-site2.sh
echo pm2 delete site2-backend 2^>/dev/null >> temp-install-site2.sh
echo pm2 delete site2-frontend 2^>/dev/null >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # מפעיל עם PM2 >> temp-install-site2.sh
echo echo "[7] מפעיל את השירותים..." >> temp-install-site2.sh
echo pm2 start server.js --name site2-backend >> temp-install-site2.sh
echo cd .. >> temp-install-site2.sh
echo pm2 serve dist 9000 --name site2-frontend --spa >> temp-install-site2.sh
echo pm2 save >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # מגדיר Nginx >> temp-install-site2.sh
echo echo "[8] מגדיר את Nginx..." >> temp-install-site2.sh
echo cat ^> /etc/nginx/sites-available/site2 ^<^< 'EOF' >> temp-install-site2.sh
echo server { >> temp-install-site2.sh
echo     listen 8081; >> temp-install-site2.sh
echo     server_name _; >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo     location / { >> temp-install-site2.sh
echo         proxy_pass http://localhost:9000; >> temp-install-site2.sh
echo         proxy_http_version 1.1; >> temp-install-site2.sh
echo         proxy_set_header Upgrade $http_upgrade; >> temp-install-site2.sh
echo         proxy_set_header Connection "upgrade"; >> temp-install-site2.sh
echo         proxy_set_header Host $host; >> temp-install-site2.sh
echo         proxy_cache_bypass $http_upgrade; >> temp-install-site2.sh
echo     } >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo     location /api { >> temp-install-site2.sh
echo         proxy_pass http://localhost:4000; >> temp-install-site2.sh
echo         proxy_http_version 1.1; >> temp-install-site2.sh
echo         proxy_set_header Upgrade $http_upgrade; >> temp-install-site2.sh
echo         proxy_set_header Connection "upgrade"; >> temp-install-site2.sh
echo         proxy_set_header Host $host; >> temp-install-site2.sh
echo         proxy_cache_bypass $http_upgrade; >> temp-install-site2.sh
echo     } >> temp-install-site2.sh
echo } >> temp-install-site2.sh
echo EOF >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # מפעיל את האתר ב-Nginx >> temp-install-site2.sh
echo ln -sf /etc/nginx/sites-available/site2 /etc/nginx/sites-enabled/ >> temp-install-site2.sh
echo nginx -t ^&^& systemctl reload nginx >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo # פותח פורטים >> temp-install-site2.sh
echo echo "[9] פותח פורטים בחומת האש..." >> temp-install-site2.sh
echo ufw allow 4000/tcp >> temp-install-site2.sh
echo ufw allow 9000/tcp >> temp-install-site2.sh
echo ufw allow 8081/tcp >> temp-install-site2.sh
echo ufw reload >> temp-install-site2.sh
echo. >> temp-install-site2.sh
echo echo "" >> temp-install-site2.sh
echo echo "========== בדיקות סופיות ==========" >> temp-install-site2.sh
echo echo "" >> temp-install-site2.sh
echo echo "PM2 Status:" >> temp-install-site2.sh
echo pm2 list ^| grep site2 >> temp-install-site2.sh
echo echo "" >> temp-install-site2.sh
echo echo "Port Check:" >> temp-install-site2.sh
echo netstat -tlnp ^| grep -E "4000^|9000^|8081" >> temp-install-site2.sh
echo echo "" >> temp-install-site2.sh
echo echo "========== סיום התקנה ==========" >> temp-install-site2.sh
echo echo "site2 מותקן ופועל!" >> temp-install-site2.sh
echo echo "" >> temp-install-site2.sh
echo echo "גישה:" >> temp-install-site2.sh
echo echo "- אתר ראשי: http://31.97.129.5:8081" >> temp-install-site2.sh
echo echo "- Backend: http://31.97.129.5:4000" >> temp-install-site2.sh
echo echo "- Frontend: http://31.97.129.5:9000" >> temp-install-site2.sh

echo.
echo [2] מעלה ומריץ בשרת...
echo ================================

REM מעלה את הסקריפט
scp temp-install-site2.sh root@31.97.129.5:/tmp/install-site2.sh

REM מריץ את הסקריפט
ssh root@31.97.129.5 "chmod +x /tmp/install-site2.sh && /tmp/install-site2.sh"

REM מוחק את הקובץ הזמני
del temp-install-site2.sh

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
pause