@echo off
chcp 65001 >nul
echo ================================================
echo    העלאת מערכת טיוטות באמצעות WinSCP
echo ================================================
echo.
echo פתח את WinSCP והתחבר ל: 31.97.129.5
echo.
echo 1. עבור לתיקייה: /home/emailapp/site2
echo.
echo 2. חפש את תיקיית pages (כנראה בתוך src או app)
echo.
echo 3. העלה את הקבצים הבאים לתיקיית pages:
echo    - src\pages\Layout.jsx
echo    - src\pages\Inbox.jsx 
echo    - src\pages\PendingReplies.jsx
echo    - src\pages\index.jsx
echo.
echo 4. העלה את backend\server.js ל:
echo    /home/emailapp/site2/backend/server.js
echo.
echo 5. אחרי ההעלאה, הפעל בטרמינל:
echo    ssh root@31.97.129.5
echo    cd /home/emailapp/site2
echo    npm run build
echo    pm2 restart site2-backend
echo    pm2 restart site2-frontend
echo.
echo ================================================
echo לחלופין, הפעל את CHECK-SITE2-STRUCTURE.bat
echo כדי לראות את המבנה המדויק
echo ================================================
pause