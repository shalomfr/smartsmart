@echo off
echo ================================================
echo   מעלה תמיכה בתוויות ל-site2
echo ================================================
echo.

echo [1] מעלה את server.js עם תמיכה בתוויות...
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [2] מפעיל מחדש את הבקאנד...
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [3] בודק שהכל עובד...
timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "pm2 list | grep site2-backend"

echo.
echo ================================================
echo   ✅ התוויות הועלו בהצלחה!
echo ================================================
echo.
echo עכשיו ב-site2 יש:
echo - תוויות ליד כל מייל
echo - תרגום אוטומטי לעברית
echo - תמיכה ב-Gmail labels
echo.
echo בדוק ב: http://31.97.129.5:8081
echo.
pause