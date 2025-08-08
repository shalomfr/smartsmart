@echo off
chcp 65001 >nul
echo ================================================
echo    העלאת כל תיקיית src באמצעות TAR
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo [1] יוצר ארכיון TAR של תיקיית src...
tar -czf src.tar.gz src

echo.
echo [2] מעלה את הארכיון...
scp src.tar.gz %USER%@%SERVER%:%REMOTE_PATH%/

echo.
echo [3] מחלץ בשרת...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && rm -rf src_backup && mv src src_backup 2>/dev/null && tar -xzf src.tar.gz && rm src.tar.gz"

echo.
echo [4] מעלה server.js...
scp backend\server.js %USER%@%SERVER%:%REMOTE_PATH%/backend/server.js

echo.
echo [5] בונה את האפליקציה...
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && npm run build"

echo.
echo [6] מפעיל מחדש...
ssh %USER%@%SERVER% "pm2 restart site2-backend && pm2 restart site2-frontend"

echo.
echo [7] מוחק ארכיון מקומי...
del src.tar.gz 2>nul

echo.
echo ================================================
echo       ✓ הושלם!
echo ================================================
echo.
echo אם משהו השתבש, התיקייה הישנה נשמרה ב-src_backup
echo.
echo כתובת האתר: http://31.97.129.5:8081
echo.
pause