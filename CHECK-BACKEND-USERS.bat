@echo off
chcp 65001 >nul
cls
echo ================================================
echo      בדיקת משתמשים ב-Backend
echo ================================================
echo.

echo [1] בודק משתמשי בדיקה...
echo ========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -A20 'const users' server.js"

echo.
echo [2] בודק הגדרות CORS...
echo =======================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -B5 -A5 'cors' server.js"

echo.
echo [3] בודק אם השרת מאזין...
echo =========================
ssh root@31.97.129.5 "curl -s http://localhost:4000/api/health || echo 'Backend לא מגיב'"

echo.
echo [4] מנסה כניסה ישירה...
echo ========================
ssh root@31.97.129.5 "curl -X POST http://localhost:4000/api/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"admin@example.com\",\"password\":\"admin123\"}'"

echo.
pause