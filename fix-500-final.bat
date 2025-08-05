@echo off
echo =============================================
echo   🎯 תיקון סופי עם פורט 3003
echo =============================================
echo.

echo 📤 מעלה שינוי פורט לגיטהאב...
cd /d "C:\mail\0548481658"
git add backend/server.js
git commit -m "Change default port to 3003 to avoid conflicts" 2>nul
git push origin main 2>nul

echo.
echo 🔧 מתקן את השרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && pm2 delete all && cd backend && echo 'PORT=3003' > .env && pm2 start server.js --name email-app-backend && cd .. && pm2 serve dist 8080 --name email-app-frontend --spa && sed -i 's/localhost:[0-9]*/localhost:3003/g' /etc/nginx/sites-available/email-app && nginx -s reload && pm2 save --force && pm2 status"

echo.
echo =============================================
echo ✅ הכל אמור לעבוד עכשיו!
echo =============================================
echo.
echo נסה: http://31.97.129.5
echo.
pause