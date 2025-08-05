@echo off
echo ===== תיקון חירום מהיר =====
echo.

echo [1] דוחף קוד ל-GitHub...
git add . >nul 2>&1
git commit -m "Emergency fix" >nul 2>&1
git push --force >nul 2>&1
echo    [OK] GitHub updated

echo.
echo [2] מתקן בשרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm install && npm run build && cd backend && npm install && echo 'PORT=3001' > .env && pm2 start server.js --name backend && cd .. && pm2 serve dist 8080 --name frontend --spa && pm2 save"

echo.
echo [3] בדיקה...
ssh root@31.97.129.5 "pm2 list"

echo.
echo נסה עכשיו:
echo - http://31.97.129.5:8080
echo - http://31.97.129.5
echo.
pause