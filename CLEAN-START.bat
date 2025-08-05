@echo off
echo ================================================
echo    התחלה נקייה - מתקן הכל מאפס
echo ================================================
echo.

echo שלב 1: דוחף לגיטהאב...
git add . && git commit -m "Fix all issues" && git push --force

echo.
echo שלב 2: מנקה הכל בשרת...
ssh root@31.97.129.5 "pm2 kill && systemctl stop nginx && killall -9 node 2>/dev/null"

echo.
echo שלב 3: מושך קוד נקי...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git fetch --all && git reset --hard origin/main"

echo.
echo שלב 4: מתקין מחדש...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && rm -rf node_modules dist && npm install && npm run build"

echo.
echo שלב 5: מתקין Backend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && rm -rf node_modules && npm install && echo 'PORT=3001' > .env"

echo.
echo שלב 6: מפעיל שירותים...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && pm2 start server.js --name backend && cd .. && pm2 serve dist 80 --name frontend --spa && pm2 save"

echo.
echo שלב 7: בדיקה...
timeout /t 5 /nobreak >nul
ssh root@31.97.129.5 "pm2 list"

echo.
echo ================================================
echo הושלם! נסה עכשיו: http://31.97.129.5
echo ================================================
echo.
pause