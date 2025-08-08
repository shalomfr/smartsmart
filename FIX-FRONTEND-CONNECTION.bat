@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *      תיקון חיבור Frontend ל-Backend             *
echo ****************************************************
echo.

echo [1] בודק מה ה-URL שה-Frontend משתמש...
echo =======================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && grep -o 'http://[^\"]*' *.js | grep -E 'api|4000|3001' | sort -u | head -10"

echo.
echo [2] מעדכן את AuthContext.jsx...
echo ================================
(
echo // שורה 33-35 ב-AuthContext.jsx
echo const API_URL = window.location.hostname === 'localhost' 
echo   ? 'http://localhost:4000/api' 
echo   : 'http://31.97.129.5:4000/api';
) > auth-fix.txt

type auth-fix.txt
echo.

echo [3] מעלה את הקובץ המתוקן...
echo ============================
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace \"const API_URL = window.location.hostname === 'localhost'.*\r?\n.*\? 'http://localhost:3001/api'.*\r?\n.*: '/api';\", \"const API_URL = window.location.hostname === 'localhost' ? 'http://localhost:4000/api' : 'http://31.97.129.5:4000/api';\" | Set-Content src\contexts\AuthContext.jsx"

scp src/contexts/AuthContext.jsx root@31.97.129.5:/home/emailapp/site2/src/contexts/

echo.
echo [4] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [5] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart site2-frontend"

echo.
echo ****************************************************
echo *              זהו! עכשיו תעבוד!                  *
echo ****************************************************
echo.
echo היכנס ל: http://31.97.129.5:8082
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
pause