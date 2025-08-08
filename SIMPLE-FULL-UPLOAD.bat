@echo off
chcp 65001 >nul
echo ================================================
echo      העלאה פשוטה של כל הפרויקט
echo ================================================
echo.

echo אפשרות 1: העתקת כל תיקיית src
echo ========================================
echo.
echo 1. פתח WinSCP
echo 2. התחבר ל-31.97.129.5
echo 3. עבור ל: /home/emailapp/site2
echo 4. מחק את תיקיית src הישנה (אם קיימת)
echo 5. העתק את כל תיקיית src מהמחשב שלך
echo 6. העתק את backend\server.js ל-backend\server.js
echo.
echo 7. בטרמינל הפעל:
echo    ssh root@31.97.129.5
echo    cd /home/emailapp/site2
echo    npm run build
echo    pm2 restart site2-backend
echo    pm2 restart site2-frontend
echo.
echo ========================================
echo.
echo אפשרות 2: העלאה מינימלית (רק הנדרש)
echo ========================================
echo.
pause

echo [1] מנסה להעלות רק את הקבצים החדשים...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [2] יוצר תיקיות...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && mkdir -p src/pages"

echo.
echo [3] מעלה את 4 הקבצים העיקריים...
scp src\pages\Layout.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src\pages\Inbox.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src\pages\PendingReplies.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src\pages\index.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/

echo.
echo [4] מנסה לבנות...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build 2>&1 | head -20"

echo.
echo אם יש שגיאות - השתמש ב-WinSCP!
echo.
pause