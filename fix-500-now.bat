@echo off
echo =============================================
echo   ⚡ תיקון מהיר לשגיאת 500
echo =============================================
echo.

echo 🔧 מתקן את השרת...
ssh root@31.97.129.5 "pm2 delete all && cd /home/emailapp/email-app/backend && echo 'PORT=3002' > .env && pm2 start server.js --name email-app-backend && cd .. && pm2 serve dist 8080 --name email-app-frontend --spa && sed -i 's/localhost:3001/localhost:3002/g' /etc/nginx/sites-available/email-app && nginx -s reload && pm2 save --force"

echo.
echo ✅ השרת אמור לעבוד עכשיו!
echo.
echo 🌐 נסה שוב: http://31.97.129.5
echo.
pause