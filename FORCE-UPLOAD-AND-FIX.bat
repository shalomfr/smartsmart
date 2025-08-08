@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *         תיקון כוחני - נעלה הכל מחדש            *
echo ****************************************************
echo.

echo שלב 1: עוצר הכל בשרת...
echo ========================
ssh root@31.97.129.5 "pm2 stop all"

echo.
echo שלב 2: מוחק קבצים ישנים בשרת...
echo =================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && rm -f Layout.jsx Inbox.jsx PendingReplies.jsx index.jsx"
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && rm -f server.js"

echo.
echo שלב 3: מעלה קבצים חדשים...
echo ============================
echo מעלה Layout.jsx...
scp -v src/pages/Layout.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo מעלה Inbox.jsx...
scp -v src/pages/Inbox.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo מעלה PendingReplies.jsx...
scp -v src/pages/PendingReplies.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo מעלה index.jsx...
scp -v src/pages/index.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo מעלה server.js...
scp -v backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo שלב 4: בודק שהקבצים הועלו...
echo =============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'קבצים שהועלו:' && ls -la *.jsx | grep -E '(Layout|Inbox|PendingReplies|index)'"

echo.
echo שלב 5: מוחק dist ישן...
echo =======================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && rm -rf dist/ node_modules/.cache"

echo.
echo שלב 6: בונה מחדש...
echo ===================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo שלב 7: מפעיל הכל מחדש...
echo ========================
ssh root@31.97.129.5 "pm2 start all"

echo.
echo ****************************************************
echo *                  סיום!                           *
echo ****************************************************
echo.
echo עכשיו:
echo 1. סגור את כל הדפדפנים
echo 2. פתח CMD חדש והקלד: ipconfig /flushdns
echo 3. פתח דפדפן בגלישה פרטית (Ctrl+Shift+N)
echo 4. היכנס ל: http://31.97.129.5:8081
echo.
echo ****************************************************
echo.
pause