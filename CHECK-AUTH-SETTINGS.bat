@echo off
chcp 65001 >nul
cls
echo ================================================
echo      בדיקת הגדרות אימות
echo ================================================
echo.

echo [1] בודק את קובץ settingsAPI.js...
echo ===================================
type src\api\settingsAPI.js | findstr /n "apiUrl password"

echo.
echo [2] בודק CORS בשרת...
echo =====================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'cors' server.js | head -5"

echo.
echo [3] בודק את mock users...
echo ========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -A10 'mockUsers' server.js"

echo.
echo [4] בודק אם יש בעיות CORS...
echo ============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'localhost' server.js"

echo.
echo ================================================
echo   אם אתה רואה localhost - זו הבעיה!
echo   צריך לשנות ל-31.97.129.5
echo ================================================
echo.
pause