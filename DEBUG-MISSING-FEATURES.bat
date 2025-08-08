@echo off
chcp 65001 >nul
echo ================================================
echo       דיבוג - למה אין טיוטות?
echo ================================================
echo.

echo [1] בודק אם הקבצים בכלל הועלו...
echo.
echo Layout.jsx:
scp src\pages\Layout.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/Layout.jsx
echo Inbox.jsx:
scp src\pages\Inbox.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/Inbox.jsx
echo PendingReplies.jsx:
scp src\pages\PendingReplies.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/PendingReplies.jsx
echo index.jsx:
scp src\pages\index.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/index.jsx
echo server.js:
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [2] בודק שהקבצים מכילים את הקוד הנכון...
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2 && echo '=== בדיקות קוד ===' && echo 'תיקייה בתפריט:' && grep -c 'בהמתנה לתשובה' src/pages/Layout.jsx && echo 'כפתור טיוטה:' && grep -c 'צור טיוטה' src/pages/Inbox.jsx && echo 'דף טיוטות:' && head -5 src/pages/PendingReplies.jsx | grep PendingReplies && echo 'נתיב בראוטר:' && grep -c PendingReplies src/pages/index.jsx && echo 'API בשרת:' && grep -c 'DRAFTS API' backend/server.js"

echo.
echo [3] בונה עם הצגת שגיאות...
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build 2>&1 | tail -20"

echo.
echo [4] מפעיל מחדש ובודק לוגים...
echo.
ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend && sleep 2 && pm2 logs --lines 10 --nostream"

echo.
echo ================================================
echo אם אתה עדיין לא רואה:
echo 1. נקה מטמון דפדפן (Ctrl+Shift+Delete)
echo 2. פתח בחלון פרטי/גלישה בסתר
echo 3. בדוק בכלי פיתוח (F12) בכרטיסיית Network
echo    שהקבצים החדשים נטענים
echo ================================================
pause