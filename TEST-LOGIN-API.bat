@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *          בדיקת API ישירות                      *
echo ****************************************************
echo.

echo [1] בודק אם API עובד ישירות...
echo ================================
ssh root@31.97.129.5 "curl -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}' -v"

echo.
echo [2] בודק מהדפדפן...
echo ===================
ssh root@31.97.129.5 "curl -X POST http://31.97.129.5:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"

echo.
echo [3] בודק endpoints זמינים...
echo ============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'app\.\(get\|post\|put\|delete\)(' server.js | grep -E '/(api|auth)/' | head -10"

echo.
echo ****************************************************
echo *               סיכום                             *
echo ****************************************************
echo.
echo אם ה-API עובד (מחזיר success: true):
echo נסה להתחבר ב: http://31.97.129.5:8082
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
echo אם לא - הפעל: FIX-FRONTEND-API.bat
echo.
pause