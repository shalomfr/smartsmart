@echo off
chcp 65001 >nul
cls
echo ================================================
echo      העלאת כל קבצי הטיוטות לשרת
echo ================================================
echo.

echo [1] מעלה את Layout.jsx המעודכן...
scp src/pages/Layout.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo [2] מעלה את Inbox.jsx המעודכן...
scp src/pages/Inbox.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo [3] מעלה את PendingReplies.jsx...
scp src/pages/PendingReplies.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo [4] מעלה את index.jsx (routing)...
scp src/pages/index.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo [5] מעלה את server.js עם ה-API...
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo [6] מוודא שהקבצים הועלו...
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && ls -la Layout.jsx Inbox.jsx PendingReplies.jsx index.jsx"

echo.
echo [7] בונה מחדש את הפרויקט...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [8] מפעיל מחדש את השרתים...
ssh root@31.97.129.5 "pm2 restart site2-frontend site2-backend"

echo.
echo ================================================
echo   הכל הועלה ונבנה מחדש!
echo   
echo   עכשיו תפתח דפדפן חדש ב:
echo   http://31.97.129.5:8081
echo ================================================
echo.
pause