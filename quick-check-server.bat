@echo off
echo =============================================
echo   בדיקה מהירה של השרת
echo =============================================
echo.

echo 1. בודק תהליכים...
ssh root@31.97.129.5 "pm2 status"

echo.
echo 2. בודק nginx...
ssh root@31.97.129.5 "nginx -t"

echo.
echo 3. בודק לוגים אחרונים...
ssh root@31.97.129.5 "tail -20 /var/log/nginx/error.log"

echo.
echo 4. בודק תיקיית dist...
ssh root@31.97.129.5 "ls -la /home/emailapp/email-app/dist/"

echo.
pause