@echo off
chcp 65001 >nul
cls
echo ================================================
echo     התקנת מערכת טיוטות מההתחלה
echo ================================================
echo.
echo זה יעלה את כל הקבצים הנדרשים ויבנה מחדש
echo.
pause

echo.
echo שלב 1: העלאת קבצים...
echo ========================
echo.

echo מעלה Backend...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo מעלה Frontend...
scp src\pages\Layout.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/Layout.jsx
scp src\pages\Inbox.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/Inbox.jsx  
scp src\pages\PendingReplies.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/PendingReplies.jsx
scp src\pages\index.jsx root@31.97.129.5:/home/emailapp/site2/src/pages/index.jsx

echo.
echo שלב 2: אימות הקבצים...
echo ========================
echo.

ssh root@31.97.129.5 "cd /home/emailapp/site2 && echo 'קבצים שהועלו:' && ls -la src/pages/*.jsx | grep -E '(Layout|Inbox|PendingReplies|index)' && echo && echo 'בדיקת תוכן:' && grep -l 'בהמתנה לתשובה' src/pages/Layout.jsx && grep -l 'צור טיוטה' src/pages/Inbox.jsx && grep -l 'PendingReplies' src/pages/index.jsx"

echo.
echo שלב 3: ניקוי ובנייה...
echo ========================
echo.

ssh root@31.97.129.5 "cd /home/emailapp/site2 && echo 'מנקה build ישן...' && rm -rf dist && echo 'בונה מחדש...' && npm run build"

echo.
echo שלב 4: הפעלה מחדש...
echo ========================
echo.

ssh root@31.97.129.5 "pm2 stop site2-backend site2-frontend && pm2 start site2-backend && pm2 start site2-frontend && pm2 save"

echo.
echo שלב 5: בדיקה סופית...
echo ========================
echo.

ssh root@31.97.129.5 "pm2 status | grep site2"

echo.
echo ================================================
echo               הושלם!
echo ================================================
echo.
echo כעת:
echo 1. פתח דפדפן חדש או מצב גלישה בסתר
echo 2. נווט ל: http://31.97.129.5:8081
echo 3. היכנס למערכת
echo 4. אתה אמור לראות:
echo    - "בהמתנה לתשובה" בתפריט הצדדי
echo    - כפתור "צור טיוטה" כשאתה יוצר תשובה חכמה
echo.
echo אם עדיין לא - הפעל DEBUG-MISSING-FEATURES.bat
echo ================================================
echo.
pause