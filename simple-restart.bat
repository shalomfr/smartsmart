@echo off
echo =============================================
echo   🔄 הפעלה מחדש פשוטה
echo =============================================
echo.

echo מאתחל את כל השירותים...
ssh root@31.97.129.5 "pm2 restart all && nginx -s reload"

echo.
echo מחכה 5 שניות...
timeout /t 5 /nobreak > nul

echo.
echo בודק סטטוס...
ssh root@31.97.129.5 "pm2 status"

echo.
echo ✅ נסה עכשיו: http://31.97.129.5
echo.
pause