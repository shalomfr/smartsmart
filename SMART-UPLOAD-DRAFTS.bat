@echo off
chcp 65001 >nul
echo ================================================
echo     העלאת מערכת טיוטות חכמות לשרת
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo [1] בודק מבנה תיקיות בשרת...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && echo 'תיקיית pages נמצאת ב:' && find . -type d -name 'pages' | grep -v node_modules | head -1"

echo.
echo [2] מוצא את תיקיית pages...
for /f "delims=" %%i in ('ssh %USER%@%SERVER% "cd %REMOTE_PATH% && find . -type d -name 'pages' | grep -v node_modules | head -1"') do set PAGES_DIR=%%i

echo נמצאה תיקייה: %PAGES_DIR%

echo.
echo [3] מעלה קבצי Backend...
scp backend\server.js %USER%@%SERVER%:%REMOTE_PATH%/backend/server.js

echo.
echo [4] מעלה קבצי Frontend לתיקייה הנכונה...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && PAGES_DIR=\$(find . -type d -name 'pages' | grep -v node_modules | head -1) && echo \"מעלה לתיקייה: \$PAGES_DIR\""

echo.
echo מעלה Layout.jsx...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && PAGES_DIR=\$(find . -type d -name 'pages' | grep -v node_modules | head -1) && cat > \$PAGES_DIR/Layout.jsx" < src\pages\Layout.jsx

echo מעלה Inbox.jsx...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && PAGES_DIR=\$(find . -type d -name 'pages' | grep -v node_modules | head -1) && cat > \$PAGES_DIR/Inbox.jsx" < src\pages\Inbox.jsx

echo מעלה PendingReplies.jsx...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && PAGES_DIR=\$(find . -type d -name 'pages' | grep -v node_modules | head -1) && cat > \$PAGES_DIR/PendingReplies.jsx" < src\pages\PendingReplies.jsx

echo מעלה index.jsx...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && PAGES_DIR=\$(find . -type d -name 'pages' | grep -v node_modules | head -1) && cat > \$PAGES_DIR/index.jsx" < src\pages\index.jsx

echo.
echo [5] בונה את האפליקציה...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && npm run build"

echo.
echo [6] מפעיל מחדש את השרתים...
ssh %USER%@%SERVER% "pm2 restart site2-backend && pm2 restart site2-frontend"

echo.
echo [7] בודק סטטוס...
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