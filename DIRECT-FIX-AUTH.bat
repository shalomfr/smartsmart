@echo off
chcp 65001 >nul
cls
color 0B
echo ****************************************************
echo *         תיקון ישיר של AuthContext               *
echo ****************************************************
echo.

echo [1] מעדכן את AuthContext.jsx מקומית...
echo =======================================
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace '.*localhost:3001.*', '        ? ''http://localhost:4000/api''' -replace ': ''/api'';', ': ''http://'' + window.location.hostname + '':4000/api'';' | Set-Content src\contexts\AuthContext.jsx"

echo.
echo [2] מעלה לשרת...
echo =================
scp src/contexts/AuthContext.jsx root@31.97.129.5:/home/emailapp/site2/src/contexts/

echo.
echo [3] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [4] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart site2-frontend"

echo.
echo ****************************************************
echo *                 זהו!                             *
echo ****************************************************
echo.
echo עכשיו תיכנס ל: http://31.97.129.5:8082
echo.
echo עם הפרטים:
echo -----------
echo שם משתמש: admin
echo סיסמה: 123456
echo.
echo ****************************************************
echo.
pause