@echo off
chcp 65001 >nul
echo ================================================
echo     העלאת מערכת טיוטות חכמות לשרת
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo [1] מעלה קבצי Backend...
scp backend\server.js %USER%@%SERVER%:%REMOTE_PATH%/backend/server.js

echo.
echo [2] מעלה קבצי Frontend...
scp src\pages\Layout.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/Layout.jsx
scp src\pages\Inbox.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/Inbox.jsx
scp src\pages\PendingReplies.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/PendingReplies.jsx
scp src\pages\index.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/index.jsx

echo.
echo [3] בונה את האפליקציה...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && npm run build"

echo.
echo [4] מפעיל מחדש את השרתים...
ssh %USER%@%SERVER% "pm2 restart site2-backend && pm2 restart site2-frontend"

echo.
echo [5] בודק סטטוס...
ssh %USER%@%SERVER% "pm2 status"

echo.
echo ================================================
echo       ✓ מערכת הטיוטות הועלתה בהצלחה!
echo ================================================
echo.
echo מה חדש:
echo - תיקייה "בהמתנה לתשובה" בתפריט
echo - כפתור "צור טיוטה" בתשובות חכמות
echo - ניהול מלא של טיוטות עם עריכה ושליחה
echo - שמירת שרשור המיילים
echo.
echo כתובת האתר: http://31.97.129.5:8081
echo.
pause