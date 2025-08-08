@echo off
chcp 65001 >nul
echo ================================================
echo      העלאה מאולצת של מערכת הטיוטות
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo [1] יוצר תיקיות...
ssh %USER%@%SERVER% "mkdir -p %REMOTE_PATH%/src/pages %REMOTE_PATH%/src/api %REMOTE_PATH%/src/contexts %REMOTE_PATH%/src/components"

echo.
echo [2] מעלה server.js עם API טיוטות...
scp backend\server.js %USER%@%SERVER%:%REMOTE_PATH%/backend/server.js

echo.
echo [3] מוודא שה-server.js מכיל את API הטיוטות...
ssh %USER%@%SERVER% "grep -c 'DRAFTS API' %REMOTE_PATH%/backend/server.js || echo '0 - לא נמצא API טיוטות!'"

echo.
echo [4] מעלה Layout.jsx עם התיקייה החדשה...
scp src\pages\Layout.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/Layout.jsx

echo.
echo [5] מוודא שיש את התיקייה בתפריט...
ssh %USER%@%SERVER% "grep -c 'בהמתנה לתשובה' %REMOTE_PATH%/src/pages/Layout.jsx || echo '0 - לא נמצאה תיקייה בתפריט!'"

echo.
echo [6] מעלה Inbox.jsx עם כפתור צור טיוטה...
scp src\pages\Inbox.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/Inbox.jsx

echo.
echo [7] מוודא שיש כפתור צור טיוטה...
ssh %USER%@%SERVER% "grep -c 'צור טיוטה' %REMOTE_PATH%/src/pages/Inbox.jsx || echo '0 - לא נמצא כפתור!'"

echo.
echo [8] מעלה PendingReplies.jsx...
scp src\pages\PendingReplies.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/PendingReplies.jsx

echo.
echo [9] מעלה index.jsx עם הנתיב החדש...
scp src\pages\index.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/index.jsx

echo.
echo [10] מוודא את כל הקבצים...
ssh %USER%@%SERVER% "cd %REMOTE_PATH%/src/pages && ls -la | grep -E '(Layout|Inbox|PendingReplies|index)\.jsx'"

echo.
echo [11] בונה מחדש עם ניקוי...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && rm -rf dist && npm run build"

echo.
echo [12] מפעיל מחדש...
ssh %USER%@%SERVER% "pm2 restart site2-backend && pm2 restart site2-frontend"

echo.
echo ================================================
echo     בדיקה סופית
echo ================================================
echo.
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && echo 'תיקייה בתפריט:' && grep -c 'בהמתנה לתשובה' src/pages/Layout.jsx && echo 'כפתור טיוטה:' && grep -c 'צור טיוטה' src/pages/Inbox.jsx"

echo.
echo נקה את הדפדפן (Ctrl+F5) ובדוק שוב!
echo.
pause