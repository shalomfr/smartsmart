@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *         בדיקת חיבור Frontend-Backend            *
echo ****************************************************
echo.

echo [1] בודק אם Frontend מתחבר ל-Backend הנכון...
echo ==============================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && grep -o 'http://[^\"]*:4000' *.js | sort -u"

echo.
echo [2] בודק אם Backend מאפשר CORS מ-8082...
echo ========================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -B2 -A10 'cors(' server.js"

echo.
echo [3] מנסה כניסה ישירות מהשרת...
echo =================================
ssh root@31.97.129.5 "curl -X POST -v http://localhost:4000/api/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"admin@example.com\",\"password\":\"admin123\"}' 2>&1 | grep -E '(< HTTP|{)'"

echo.
echo [4] בודק לוגים של Backend...
echo =============================
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 10"

echo.
pause