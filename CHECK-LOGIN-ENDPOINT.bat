@echo off
chcp 65001 >nul
cls
echo ****************************************************
echo *         בדיקת endpoint של כניסה                *
echo ****************************************************
echo.

echo [1] בודק איזה endpoint מוגדר ב-AuthContext...
echo ==============================================
type src\contexts\AuthContext.jsx | findstr /n "/login"

echo.
echo [2] בודק אילו endpoints קיימים ב-Backend...
echo ============================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'app.post.*login' server.js"

echo.
echo [3] בודק אם יש התאמה...
echo =========================
echo.
echo ה-Frontend צריך לקרוא ל: /api/app/login
echo ה-Backend צריך להאזין ל: /api/app/login
echo.
echo אם אתה רואה /api/auth/login - זו הבעיה!
echo.
pause