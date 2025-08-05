@echo off
echo =============================================
echo   🔍 אבחון מלא של שגיאת 500
echo =============================================
echo.

echo === 1. בודק תהליכי PM2 ===
ssh root@31.97.129.5 "pm2 list"

echo.
echo === 2. בודק לוגים של PM2 ===
ssh root@31.97.129.5 "pm2 logs --lines 10"

echo.
echo === 3. בודק תיקיית dist ===
ssh root@31.97.129.5 "ls -la /home/emailapp/email-app/dist/ | head -10"

echo.
echo === 4. בודק שגיאות Nginx ===
ssh root@31.97.129.5 "tail -10 /var/log/nginx/error.log"

echo.
echo === 5. בודק פורטים תפוסים ===
ssh root@31.97.129.5 "netstat -tlnp | grep -E '3001|3002|3003|8080'"

echo.
echo === 6. בודק תהליכי Node ===
ssh root@31.97.129.5 "ps aux | grep node | grep -v grep"

echo.
echo === 7. בודק הגדרות Nginx ===
ssh root@31.97.129.5 "grep proxy_pass /etc/nginx/sites-available/email-app"

echo.
echo === 8. בודק קובץ .env ===
ssh root@31.97.129.5 "cat /home/emailapp/email-app/backend/.env 2>/dev/null || echo 'No .env file'"

echo.
echo =============================================
echo סיום אבחון. בדוק את התוצאות למעלה.
echo =============================================
echo.
pause