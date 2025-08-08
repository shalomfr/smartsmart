@echo off
chcp 65001 >nul
echo ================================================
echo    העלאת כל הקבצים הנדרשים למערכת טיוטות
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo [1] יוצר מבנה תיקיות מלא...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && mkdir -p src/{pages,api,contexts,components/{ui,MockAPI}}"

echo.
echo [2] מעלה קבצי Backend...
scp backend\server.js %USER%@%SERVER%:%REMOTE_PATH%/backend/server.js

echo.
echo [3] מעלה קבצי Pages...
echo מעלה Layout.jsx...
scp src\pages\Layout.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/
echo מעלה Inbox.jsx...
scp src\pages\Inbox.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/
echo מעלה PendingReplies.jsx...
scp src\pages\PendingReplies.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/
echo מעלה index.jsx...
scp src\pages\index.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/

echo.
echo [4] מעלה את שאר הדפים הנדרשים...
scp src\pages\Login.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul
scp src\pages\Settings.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul
scp src\pages\Compose.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul
scp src\pages\Contacts.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul
scp src\pages\SmartFeatures.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul
scp src\pages\Search.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul
scp src\pages\AITraining.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul
scp src\pages\Rules.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul
scp src\pages\Tasks.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul

echo.
echo [5] מעלה קבצי API...
scp src\api\*.js %USER%@%SERVER%:%REMOTE_PATH%/src/api/ 2>nul

echo.
echo [6] מעלה contexts...
scp src\contexts\*.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/contexts/ 2>nul

echo.
echo [7] מעלה ProtectedRoute...
scp src\components\ProtectedRoute.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/components/ 2>nul

echo.
echo [8] בודק מה הועלה...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && echo 'Pages:' && ls -la src/pages/ | grep -E '(Layout|Inbox|PendingReplies|index)\.jsx'"

echo.
echo [9] בונה את האפליקציה...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && npm run build"

echo.
echo [10] מפעיל מחדש...
ssh %USER%@%SERVER% "pm2 restart site2-backend && pm2 restart site2-frontend && pm2 status"

echo.
echo ================================================
echo אם יש שגיאות בבנייה, כנראה חסרים עוד קבצים
echo נסה את MANUAL-FULL-UPLOAD.bat
echo ================================================
pause