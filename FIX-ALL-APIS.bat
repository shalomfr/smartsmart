@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *      תיקון מקיף לכל ה-APIs                     *
echo ****************************************************
echo.

echo [1] מתקן את כל קבצי ה-API מקומית...
echo =====================================

REM תיקון settingsAPI.js
echo תיקון settingsAPI.js...
powershell -Command "(Get-Content src\api\settingsAPI.js) -replace 'const API_URL = .*', 'const API_URL = ''http://31.97.129.5:4000/api'';' -replace 'fetch\(`\$\{API_URL\}', 'fetch(`\$\{API_URL\}' | Set-Content src\api\settingsAPI.js"

REM תיקון realEmailAPI.js
echo תיקון realEmailAPI.js...
powershell -Command "(Get-Content src\api\realEmailAPI.js) -replace 'const API_URL = .*', 'const API_URL = ''http://31.97.129.5:4000/api'';' | Set-Content src\api\realEmailAPI.js"

REM תיקון claudeAPI.js
echo תיקון claudeAPI.js...
powershell -Command "(Get-Content src\api\claudeAPI.js) -replace 'const API_URL = .*', 'const API_URL = ''http://31.97.129.5:4000/api'';' | Set-Content src\api\claudeAPI.js"

echo.
echo [2] וידוא שה-export נכון ב-realEmailAPI...
echo ===========================================
echo. >> src\api\realEmailAPI.js
echo // Export for PendingReplies >> src\api\realEmailAPI.js
echo export const realEmailAPI = Account; >> src\api\realEmailAPI.js

echo.
echo [3] מעלה הכל לשרת...
echo =====================
scp -r src/api root@31.97.129.5:/home/emailapp/email-prod/src/
scp -r src/pages root@31.97.129.5:/home/emailapp/email-prod/src/
scp -r src/contexts root@31.97.129.5:/home/emailapp/email-prod/src/

echo.
echo [4] מוודא ש-Backend רץ על פורט 4000...
echo ========================================
ssh root@31.97.129.5 "pm2 delete email-backend 2>/dev/null"
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && PORT=4000 pm2 start server.js --name email-backend"

echo.
echo [5] בונה מחדש את הכל...
echo =========================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && rm -rf dist && npm run build"

echo.
echo [6] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart email-frontend"

echo.
echo [7] המתנה ובדיקה...
echo ====================
timeout /t 5 /nobreak >nul
echo.
echo בודק פורטים:
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)'"
echo.
echo בודק API:
ssh root@31.97.129.5 "curl -s http://localhost:4000/api/health || echo 'אין health endpoint'"

echo.
echo ****************************************************
echo *              הוראות חשובות                     *
echo ****************************************************
echo.
echo 1. נקה מטמון דפדפן (Ctrl+F5)
echo 2. היכנס ל: http://31.97.129.5:8081
echo.
echo אפשרות 1 - כניסה פשוטה:
echo   שם משתמש: admin
echo   סיסמה: 123456
echo.
echo אפשרות 2 - מייל אמיתי:
echo   Gmail: השתמש בסיסמת אפליקציה
echo   Outlook: סיסמה רגילה
echo.
pause