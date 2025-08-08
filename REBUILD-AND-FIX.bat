@echo off
chcp 65001 >nul
cls
color 0B
echo ****************************************************
echo *      בנייה מחדש מלאה - תיקון סופי              *
echo ****************************************************
echo.

echo [1] מעדכן AuthContext לכתובת הנכונה...
echo =======================================
powershell -Command "$content = Get-Content src\contexts\AuthContext.jsx -Raw; $content = $content -replace 'const API_URL = .*', '      const API_URL = ''http://31.97.129.5:4000/api'';'; Set-Content -Path src\contexts\AuthContext.jsx -Value $content"

echo.
echo [2] מעלה את כל הקבצים המעודכנים...
echo =====================================
echo מעלה Frontend...
scp -r src root@31.97.129.5:/home/emailapp/site2/
scp -r public package*.json vite.config.js index.html *.config.js components.json jsconfig.json root@31.97.129.5:/home/emailapp/site2/ 2>nul

echo מעלה Backend...
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo [3] בונה מחדש את הפרויקט...
echo =============================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [4] מפעיל מחדש הכל...
echo ======================
ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend"

echo.
echo [5] ממתין 5 שניות...
timeout /t 5 /nobreak >nul

echo.
echo [6] בודק שהכל עובד...
echo =====================
ssh root@31.97.129.5 "pm2 list | grep site2"
echo.
ssh root@31.97.129.5 "curl -s http://localhost:4000/api/app/login -X POST -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"

echo.
echo ****************************************************
echo *            סיימנו! נסה עכשיו                    *
echo ****************************************************
echo.
echo 1. סגור את הדפדפן לגמרי
echo 2. פתח דפדפן חדש
echo 3. היכנס ל: http://31.97.129.5:8082
echo.
echo כניסה:
echo   שם משתמש: admin
echo   סיסמה: 123456
echo.
echo ****************************************************
echo.
pause