@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *          תיקון מיידי לבעיית כניסה              *
echo ****************************************************
echo.

echo [1] מוודא שהמשתמשים מוגדרים בקובץ המקומי...
echo ============================================
findstr /n "APP_USERS admin 123456" backend\server.js

echo.
echo [2] מעלה את server.js המעודכן לשרת...
echo ======================================
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo [3] מפעיל מחדש את ה-Backend...
echo ==============================
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [4] ממתין 3 שניות...
timeout /t 3 /nobreak >nul

echo.
echo [5] בודק שה-Backend רץ...
echo ========================
ssh root@31.97.129.5 "pm2 list | grep site2-backend"

echo.
echo [6] מנסה כניסה ישירה...
echo ========================
ssh root@31.97.129.5 "curl -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"

echo.
echo ****************************************************
echo *               נסה עכשיו!                        *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8082
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
echo אם עדיין לא עובד, נסה:
echo שם משתמש: user1
echo סיסמה: password
echo.
echo ****************************************************
echo.
pause