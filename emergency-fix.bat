@echo off
echo =============================================
echo   ⚡ תיקון חירום מהיר
echo =============================================
echo.

echo רק מאתחל את התהליכים...
ssh root@31.97.129.5 "pm2 restart all && nginx -s reload"

echo.
echo בודק סטטוס...
ssh root@31.97.129.5 "pm2 status"

echo.
echo ✅ נסה עכשיו: http://31.97.129.5
echo.
pause