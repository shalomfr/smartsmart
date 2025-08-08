@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *       עדכון כל קבצי ה-API לפורט 4000            *
echo ****************************************************
echo.

echo [1] מעדכן את כל קבצי ה-API...
echo ==============================

echo מעדכן settingsAPI.js...
powershell -Command "if (Test-Path src\api\settingsAPI.js) { (Get-Content src\api\settingsAPI.js) -replace 'const apiUrl = .*', 'const apiUrl = ''http://31.97.129.5:4000'';' -replace 'http://localhost:\d+', 'http://31.97.129.5:4000' | Set-Content src\api\settingsAPI.js }"

echo מעדכן realEmailAPI.js...
powershell -Command "if (Test-Path src\api\realEmailAPI.js) { (Get-Content src\api\realEmailAPI.js) -replace 'const API_URL = .*', 'const API_URL = ''http://31.97.129.5:4000'';' -replace 'http://localhost:\d+', 'http://31.97.129.5:4000' | Set-Content src\api\realEmailAPI.js }"

echo מעדכן claudeAPI.js...
powershell -Command "if (Test-Path src\api\claudeAPI.js) { (Get-Content src\api\claudeAPI.js) -replace 'const API_URL = .*', 'const API_URL = ''http://31.97.129.5:4000'';' -replace 'http://localhost:\d+', 'http://31.97.129.5:4000' | Set-Content src\api\claudeAPI.js }"

echo.
echo [2] מעלה את כל הקבצים המעודכנים...
echo =====================================
scp -r src/api root@31.97.129.5:/home/emailapp/site2/src/
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
echo *            עדכון הושלם!                         *
echo ****************************************************
echo.
pause