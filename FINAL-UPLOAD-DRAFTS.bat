@echo off
chcp 65001 >nul
echo ================================================
echo     העלאת מערכת טיוטות חכמות לשרת
echo ================================================
echo.

echo הפעל קודם: CHECK-SITE2-STRUCTURE.bat
echo כדי לראות את מבנה התיקיות
echo.
echo ואז בחר אחת מהאפשרויות:
echo.
echo 1. SMART-UPLOAD-DRAFTS.bat - העלאה אוטומטית
echo 2. WINSCP-UPLOAD-DRAFTS.bat - הוראות להעלאה ידנית
echo.
echo אם אתה רוצה להמשיך בכל זאת, לחץ Enter...
pause >nul

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo.
echo [1] מעלה server.js...
scp backend\server.js %USER%@%SERVER%:%REMOTE_PATH%/backend/server.js

echo.
echo [2] מנסה למצוא ולהעלות קבצי Frontend...

echo בודק אם יש src/pages...
ssh %USER%@%SERVER% "if [ -d %REMOTE_PATH%/src/pages ]; then echo 'קיים src/pages'; else echo 'לא קיים src/pages'; fi"

echo בודק אם יש pages ישירות...
ssh %USER%@%SERVER% "if [ -d %REMOTE_PATH%/pages ]; then echo 'קיים pages'; else echo 'לא קיים pages'; fi"

echo.
echo מנסה להעלות לכל המיקומים האפשריים...

echo מנסה src/pages...
scp src\pages\*.jsx %USER%@%SERVER%:%REMOTE_PATH%/src/pages/ 2>nul

echo מנסה pages...
scp src\pages\*.jsx %USER%@%SERVER%:%REMOTE_PATH%/pages/ 2>nul

echo מנסה app/pages...
scp src\pages\*.jsx %USER%@%SERVER%:%REMOTE_PATH%/app/pages/ 2>nul

echo.
echo [3] בונה מחדש...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && npm run build"

echo.
echo [4] מפעיל מחדש...
ssh %USER%@%SERVER% "pm2 restart site2-backend && pm2 restart site2-frontend"

echo.
echo אם היו שגיאות, השתמש ב-WinSCP!
echo.
pause