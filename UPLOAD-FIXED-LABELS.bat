@echo off
echo ================================================
echo   מעלה תיקון תוויות פשוט
echo ================================================
echo.

echo הרץ קודם את האתר הראשי?
echo 1. רק site2
echo 2. גם האתר הראשי
echo.
set /p CHOICE="בחר אפשרות (1 או 2): "

echo.
echo [1] מעלה את הקובץ המתוקן...
echo ================================

if "%CHOICE%"=="2" (
    echo מעלה לאתר הראשי...
    scp backend/server.js root@31.97.129.5:/home/emailapp/email-app/backend/server.js
    echo.
)

echo מעלה ל-site2...
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [2] מפעיל מחדש...
echo ================================

if "%CHOICE%"=="2" (
    ssh root@31.97.129.5 "pm2 restart backend site2-backend"
) else (
    ssh root@31.97.129.5 "pm2 restart site2-backend"
)

echo.
echo [3] בודק תוויות בלוגים...
echo ================================

ssh root@31.97.129.5 "pm2 logs site2-backend --lines 20 | grep -i label || echo 'Checking labels...'"

echo.
echo ================================================
echo   ✅ העלאה הושלמה!
echo ================================================
echo.
echo אם התוויות עדיין לא בעברית:
echo.
echo 1. נקה cache בדפדפן (Ctrl+F5)
echo 2. המתן 30 שניות ונסה שוב
echo 3. נסה להתנתק ולהתחבר מחדש
echo.
echo תוויות שאמורות להופיע:
echo - "חשוב" במקום "Important\"
echo - ללא קודים כמו "-BdEF2QXq&"
echo.
pause