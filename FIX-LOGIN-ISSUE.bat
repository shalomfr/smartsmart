@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *           תיקון בעיית כניסה                     *
echo ****************************************************
echo.

echo [1] בודק משתמשים ב-Backend...
echo =============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -A30 'const users' server.js | grep -E '(email|password)'"

echo.
echo [2] בודק אם ה-API עובד...
echo =========================
ssh root@31.97.129.5 "curl -X POST http://localhost:4000/api/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"admin@example.com\",\"password\":\"admin123\"}' 2>/dev/null"

echo.
echo [3] בודק URL של API בקוד...
echo ===========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && grep -h 'apiUrl' *.js | head -3"

echo.
echo [4] בודק CORS...
echo ===============
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -A5 'cors' server.js | head -10"

echo.
echo ****************************************************
echo *              פרטי כניסה נכונים                 *
echo ****************************************************
echo.
echo נסה את כל האפשרויות האלה:
echo.
echo 1️⃣ אימייל: admin@example.com
echo    סיסמה: admin123
echo.
echo 2️⃣ אימייל: user@example.com
echo    סיסמה: password123
echo.
echo 3️⃣ אימייל: test@test.com
echo    סיסמה: test123
echo.
echo ****************************************************
echo.
pause