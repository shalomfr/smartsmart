@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *      תיקון דחוף - URLs חסרים!                  *
echo ****************************************************
echo.

echo [1] בודק את הקבצים המקומיים...
echo =================================
echo.
echo AuthContext.jsx:
type src\contexts\AuthContext.jsx | findstr /n "fetch"

echo.
echo [2] מתקן את כל ה-URLs...
echo =========================

REM תיקון AuthContext
echo מתקן AuthContext.jsx...
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace 'fetch\(`\$\{API_URL\}', 'fetch(`http://31.97.129.5:4000/api' -replace 'await fetch\(''', 'await fetch(''http://31.97.129.5:4000' -replace 'const API_URL = ''.*''', 'const API_URL = ''http://31.97.129.5:4000/api''' | Set-Content src\contexts\AuthContext.jsx"

REM תיקון API files
echo מתקן API files...
powershell -Command "Get-ChildItem src\api\*.js | ForEach-Object { $content = Get-Content $_.FullName -Raw; $content = $content -replace 'const API_URL = .*;', 'const API_URL = ''http://31.97.129.5:4000'';'; $content = $content -replace 'const apiUrl = .*;', 'const apiUrl = ''http://31.97.129.5:4000'';'; $content = $content -replace 'fetch\(`\$\{API_URL\}', 'fetch(`http://31.97.129.5:4000'; Set-Content $_.FullName $content }"

echo.
echo [3] בודק שוב אחרי התיקון...
echo =============================
type src\contexts\AuthContext.jsx | findstr /n "31.97.129.5:4000"

echo.
echo [4] מעלה הכל לשרת...
echo =====================
scp -r src root@31.97.129.5:/home/emailapp/site2/

echo.
echo [5] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [6] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart site2-frontend site2-backend"

echo.
echo ****************************************************
echo *              תיקון הושלם!                       *
echo ****************************************************
echo.
echo נקה מטמון ונסה שוב:
echo http://31.97.129.5:8082
echo.
pause