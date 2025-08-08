@echo off
chcp 65001 >nul
echo ================================================
echo     העלאה ודיבוג של תוויות Gmail
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set PASSWORD=o&$M]m^^7Cc~~k@7=
set REMOTE_PATH=/home/emailapp/site2/backend/server.js
set LOCAL_PATH=backend\server.js

echo [1] מעלה את הקובץ המעודכן...
scp "%LOCAL_PATH%" %USER%@%SERVER%:%REMOTE_PATH%

echo.
echo [2] מפעיל מחדש את השרת...
ssh %USER%@%SERVER% "cd /home/emailapp/site2 && pm2 restart site2-backend"

echo.
echo [3] מחכה 5 שניות לאתחול...
timeout /t 5 >nul

echo.
echo [4] מציג לוגים חיים (Ctrl+C לעצירה)...
echo.
echo === תפתח כרטיסייה חדשה בדפדפן וטען מייל חדש ===
echo === אז תראה כאן את כל התוויות הגולמיות ===
echo.
ssh %USER%@%SERVER% "pm2 logs site2-backend --lines 50 | grep -A 20 'Labels Debug'"

pause