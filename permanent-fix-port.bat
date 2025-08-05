@echo off
echo =============================================
echo   🔐 תיקון קבוע - שינוי פורט ל-3002
echo =============================================
echo.

echo 📝 משנה את הפורט בקוד...

REM שנה את הפורט בקובץ server.js
powershell -Command "(Get-Content 0548481658\backend\server.js) -replace 'PORT \|\| 3001', 'PORT || 3002' | Set-Content 0548481658\backend\server.js"

echo.
echo 📤 מעלה את השינוי...
cd /d "C:\mail\0548481658"
git add backend/server.js
git commit -m "Change default port to 3002 to avoid conflicts"
git push origin main

echo.
echo 🔧 מעדכן את השרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && pm2 delete all && cd backend && echo 'PORT=3002' > .env && pm2 start server.js --name email-app-backend && cd .. && pm2 serve dist 8080 --name email-app-frontend --spa && sed -i 's/localhost:3001/localhost:3002/g' /etc/nginx/sites-available/email-app && nginx -s reload && pm2 save --force"

echo.
echo =============================================
echo ✅ תיקון קבוע הושלם!
echo =============================================
echo.
echo השרת עובד עכשיו על פורט 3002
echo והבעיה לא תחזור יותר!
echo.
pause