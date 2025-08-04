@echo off
echo ========================================
echo   מתקן את ה-Backend עכשיו
echo ========================================
echo.

echo מריץ פקודות תיקון בשרת...
ssh root@31.97.129.5 "apt-get update && apt-get install -y lsof && lsof -ti:3001 | xargs kill -9 && cd /home/emailapp/email-app/backend && echo 'PORT=3002' > .env && pm2 delete email-app-backend && pm2 start server.js --name email-app-backend && sed -i 's/localhost:3001/localhost:3002/g' /etc/nginx/sites-available/email-app && nginx -s reload && pm2 status"

echo.
echo ✅ Backend אמור לעבוד עכשיו!
echo.
echo בדוק שוב את שליחת המיילים.
echo.
pause