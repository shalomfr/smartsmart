@echo off
echo =============================================
echo   🔍 אבחון בעיית Backend
echo =============================================
echo.

echo 1. בודק לוגים של PM2...
ssh root@31.97.129.5 "tail -50 /root/.pm2/logs/email-app-backend-error.log"

echo.
echo =============================================
echo 2. בודק קובץ server.js...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && head -20 server.js"

echo.
echo =============================================
echo 3. בודק תלויות...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && ls node_modules"

echo.
echo =============================================
echo 4. בודק מה תופס את פורט 3001...
ssh root@31.97.129.5 "netstat -tlnp | grep 3001"

echo.
echo =============================================
echo 5. בודק הגדרות נוכחיות...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && cat .env"

echo.
pause