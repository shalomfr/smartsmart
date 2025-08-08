@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *     העלאה סופית ובנייה - זה יעבוד!             *
echo ****************************************************
echo.

echo [1/5] מעלה את כל הקבצים לשרת...
echo ==================================
scp src/pages/Layout.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src/pages/Inbox.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src/pages/PendingReplies.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp src/pages/index.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo [2/5] מוחק build ישן...
echo =======================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && rm -rf dist/"

echo.
echo [3/5] בונה את הפרויקט מחדש...
echo ==============================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [4/5] מפעיל מחדש את השרתים...
echo ==============================
ssh root@31.97.129.5 "pm2 restart site2-frontend site2-backend"

echo.
echo [5/5] מוודא שהכל נבנה נכון...
echo =============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && ls -la *.js | head -3"

echo.
echo ****************************************************
echo *              🎉 סיימנו בהצלחה! 🎉                *
echo ****************************************************
echo.
echo 📌 הוראות חשובות:
echo.
echo 1. סגור את הדפדפן לגמרי (כל החלונות)
echo 2. פתח דפדפן חדש
echo 3. לחץ Ctrl+Shift+N (חלון פרטי)
echo 4. היכנס ל: http://31.97.129.5:8081
echo.
echo 🎯 מה תראה:
echo    ✓ "בהמתנה לתשובה" בתפריט הצדדי (מעל "נשלח")
echo    ✓ כפתור סגול "צור טיוטה" כשעונים למייל
echo.
echo ****************************************************
echo.
pause