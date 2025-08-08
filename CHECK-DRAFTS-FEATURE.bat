@echo off
chcp 65001 >nul
echo ================================================
echo       בדיקת מערכת הטיוטות
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo [1] בודק אם הקבצים הועלו...
echo.
echo === בודק server.js ===
ssh %USER%@%SERVER% "grep -n 'DRAFTS API' %REMOTE_PATH%/backend/server.js | head -3"

echo.
echo === בודק PendingReplies.jsx ===
ssh %USER%@%SERVER% "ls -la %REMOTE_PATH%/src/pages/PendingReplies.jsx 2>&1"

echo.
echo === בודק Layout.jsx (תיקייה בתפריט) ===
ssh %USER%@%SERVER% "grep -n 'בהמתנה לתשובה' %REMOTE_PATH%/src/pages/Layout.jsx 2>&1 | head -3"

echo.
echo === בודק Inbox.jsx (כפתור צור טיוטה) ===
ssh %USER%@%SERVER% "grep -n 'צור טיוטה' %REMOTE_PATH%/src/pages/Inbox.jsx 2>&1 | head -3"

echo.
echo === בודק index.jsx (routing) ===
ssh %USER%@%SERVER% "grep -n 'PendingReplies' %REMOTE_PATH%/src/pages/index.jsx 2>&1 | head -3"

echo.
echo [2] בודק אם יש שגיאות בבנייה...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && npm run build 2>&1 | grep -i error | head -10"

echo.
echo [3] בודק לוגים...
echo.
echo === Backend Logs ===
ssh %USER%@%SERVER% "pm2 logs site2-backend --lines 20 --nostream | grep -i error | head -5"

echo.
echo === Frontend Logs ===
ssh %USER%@%SERVER% "pm2 logs site2-frontend --lines 20 --nostream | grep -i error | head -5"

echo.
pause