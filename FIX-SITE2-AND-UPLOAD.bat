@echo off
chcp 65001 >nul
echo ================================================
echo     תיקון site2 והעלאת מערכת טיוטות
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo [1] מתקן הרשאות ומבנה תיקיות...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && chmod -R 755 src backend && rm -rf 'backend ' && mkdir -p src/pages src/components/ui src/api src/contexts"

echo.
echo [2] מעלה קבצי Backend...
scp backend\server.js %USER%@%SERVER%:%REMOTE_PATH%/backend/server.js

echo.
echo [3] יוצר תיקיות נוספות אם צריך...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && mkdir -p src/pages src/components/ui src/api"

echo.
echo [4] מעלה קבצי Pages...
scp src\pages\Layout.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/Layout.jsx
scp src\pages\Inbox.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/Inbox.jsx
scp src\pages\PendingReplies.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/PendingReplies.jsx
scp src\pages\index.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/index.jsx

echo.
echo [5] מעלה קבצי API...
scp src\api\realEmailAPI.js %USER%@%SERVER%:%REMOTE_PATH%/src/api/realEmailAPI.js 2>nul
scp src\api\claudeAPI.js %USER%@%SERVER%:%REMOTE_PATH%/src/api/claudeAPI.js 2>nul

echo.
echo [6] מעלה contexts...
scp src\contexts\AuthContext.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/contexts/AuthContext.jsx 2>nul

echo.
echo [7] מעלה components...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && find src/components -name '*.jsx' | head -5"

echo.
echo [8] בונה את האפליקציה...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && npm run build"

echo.
echo [9] מפעיל מחדש את השרתים...
ssh %USER%@%SERVER% "pm2 restart site2-backend && pm2 restart site2-frontend"

echo.
echo [10] בודק סטטוס...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && ls -la src/pages/"

echo.
echo ================================================
echo       ✓ הושלם!
echo ================================================
echo.
echo כתובת האתר: http://31.97.129.5:8081
echo.
pause