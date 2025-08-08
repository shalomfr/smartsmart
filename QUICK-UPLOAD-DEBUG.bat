@echo off
echo מעלה קובץ מעודכן...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js
echo מפעיל מחדש...
ssh root@31.97.129.5 "pm2 restart site2-backend"
echo.
echo === עכשיו פתח את האתר וטען מייל ===
echo === ואז הפעל VIEW-LABEL-LOGS.bat ===
pause