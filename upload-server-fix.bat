@echo off
echo ==============================================
echo העלאת backend/server.js לשרת
echo ==============================================

echo.
echo מעלה את הקובץ ל-email-prod...
scp backend\server.js root@31.97.129.5:/home/emailapp/email-prod/backend/server.js

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [✓] הקובץ הועלה בהצלחה!
    echo.
    echo מפעיל מחדש את ה-backend...
    ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && pm2 restart email-backend"
    echo.
    echo בודק סטטוס...
    ssh root@31.97.129.5 "pm2 list"
) else (
    echo.
    echo [X] שגיאה בהעלאת הקובץ!
)

echo.
echo ==============================================
echo הסתיים!
echo ==============================================
pause