@echo off
chcp 65001 >nul
echo ================================================
echo      בדיקת בעיות Routing
echo ================================================
echo.

echo בודק את index.jsx המקומי...
echo ============================
echo.
type src\pages\index.jsx | findstr /n "PendingReplies"

echo.
echo בודק את הקובץ בשרת...
echo ======================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && grep -n 'PendingReplies' index.jsx"

echo.
echo בודק את App.jsx...
echo ==================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src && grep -n 'pages' App.jsx"

echo.
echo בודק מבנה תיקיות...
echo ===================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && find . -name 'PendingReplies.jsx' 2>/dev/null"

echo.
pause