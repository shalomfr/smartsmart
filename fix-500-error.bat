@echo off
echo =============================================
echo   🚨 תיקון שגיאת 500
echo =============================================
echo.

echo 🔧 מתחבר לשרת ומתקן...
echo.

ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm install && npm run build && cd backend && npm install && pm2 delete all && pm2 start server.js --name email-app-backend && cd .. && pm2 serve dist 8080 --name email-app-frontend --spa && pm2 save && nginx -s reload && echo '✅ תיקון הושלם!' && pm2 status"

echo.
echo =============================================
echo ✅ השרת אמור לעבוד עכשיו!
echo =============================================
echo.
echo נסה שוב: http://31.97.129.5
echo.
pause