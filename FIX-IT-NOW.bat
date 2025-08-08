@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *        תיקון מיידי - העלאה ובנייה               *
echo ****************************************************
echo.

echo שלב 1: מעלה את כל הקבצים...
echo ==============================
echo.
scp src/pages/Layout.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src/pages/Inbox.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src/pages/PendingReplies.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src/pages/index.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo שלב 2: בונה את הפרויקט מחדש...
echo ================================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo שלב 3: מפעיל מחדש את השרתים...
echo ================================
ssh root@31.97.129.5 "pm2 restart site2-frontend site2-backend"

echo.
echo ****************************************************
echo *                   סיימנו!                        *
echo ****************************************************
echo.
echo עכשיו:
echo 1. סגור את הדפדפן לגמרי
echo 2. פתח דפדפן חדש
echo 3. היכנס ל: http://31.97.129.5:8081
echo.
echo תראה:
echo ✓ "בהמתנה לתשובה" בתפריט (מעל "נשלח")
echo ✓ כפתור סגול "צור טיוטה" בתשובות
echo.
echo ****************************************************
echo.
pause