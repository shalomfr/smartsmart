@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *          בדיקת בעיית כניסה                     *
echo ****************************************************
echo.

echo [1] בודק אם Backend רץ...
echo ==========================
ssh root@31.97.129.5 "pm2 list | grep -E '(backend|4000)'"

echo.
echo [2] בודק משתמשים מוגדרים ב-Backend...
echo ======================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -A10 'APP_USERS' server.js"

echo.
echo [3] בודק ל-API endpoint...
echo ==========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n '/api/app/login' server.js"

echo.
echo [4] מנסה כניסה ישירה ל-API...
echo ===============================
ssh root@31.97.129.5 "curl -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}' -v"

echo.
echo [5] בודק לוגים...
echo =================
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 20 | grep -E 'login|error|Error'"

echo.
pause