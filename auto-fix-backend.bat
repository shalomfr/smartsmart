@echo off
echo =============================================
echo   🚀 תיקון אוטומטי של Backend
echo =============================================
echo.

echo מתקן את הבעיה עם הפורט...
ssh root@31.97.129.5 "pm2 delete all && cd /home/emailapp/email-app/backend && echo 'PORT=3002' > .env && npm install && pm2 start server.js --name email-app-backend --env production && cd /home/emailapp/email-app && pm2 serve dist 8080 --name email-app-frontend --spa && pm2 save"

echo.
echo מעדכן את Nginx לפורט החדש...
ssh root@31.97.129.5 "sed -i 's/localhost:3001/localhost:3002/g' /etc/nginx/sites-available/email-app && nginx -t && nginx -s reload"

echo.
echo בודק סטטוס...
ssh root@31.97.129.5 "pm2 status"

echo.
echo =============================================
echo ✅ Backend אמור לעבוד עכשיו על פורט 3002!
echo =============================================
echo.
echo אתר: http://31.97.129.5
echo.
pause