@echo off
echo ===== התחלה נקייה - בלי שגיאות =====
echo.

echo [1] דוחף קוד ל-GitHub...
git add . >nul 2>&1
git commit -m "Fresh start" >nul 2>&1
git push --force >nul 2>&1
echo    [OK] GitHub updated

echo.
echo [2] מנקה PM2 בשרת...
ssh root@31.97.129.5 "pm2 kill"

echo.
echo [3] מושך קוד ובונה...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm install && npm run build"

echo.
echo [4] מתקין Backend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && npm install && echo 'PORT=3001' > .env"

echo.
echo [5] מפעיל שירותים חדשים...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && pm2 start server.js --name backend"
ssh root@31.97.129.5 "cd /home/emailapp/email-app && pm2 serve dist 8080 --name frontend --spa"
ssh root@31.97.129.5 "pm2 save --force"

echo.
echo [6] בדיקה סופית...
ssh root@31.97.129.5 "pm2 list"

echo.
echo ===== הושלם! =====
echo נסה עכשיו:
echo - http://31.97.129.5:8080
echo - http://31.97.129.5
echo.
echo משתמש: admin
echo סיסמה: 123456
echo.
pause