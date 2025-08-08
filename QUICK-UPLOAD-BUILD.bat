@echo off
echo מעלה קבצים...
scp -q src/pages/*.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp -q backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/
echo בונה...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build > /dev/null 2>&1"
echo מפעיל מחדש...
ssh root@31.97.129.5 "pm2 restart site2-frontend site2-backend > /dev/null"
echo.
echo בוצע! פתח: http://31.97.129.5:8081
pause