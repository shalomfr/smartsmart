@echo off
echo ================================================
echo   מעלה שינויים מקומיים ל-site2
echo ================================================
echo.
echo כולל:
echo - תמיכה בתוויות (labels) למיילים
echo - כל השינויים בקוד
echo.
pause

echo.
echo [1] מעלה קבצים לשרת...
echo ================================

REM העלאת קובץ server.js המעודכן
echo מעלה backend/server.js עם תמיכה בתוויות...
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

REM העלאת קבצי Frontend אם שינית
echo.
echo מעלה קבצי Frontend...
scp -r src/* root@31.97.129.5:/home/emailapp/site2/src/ 2>nul

REM העלאת קבצים נוספים אם יש
echo.
echo מעלה package.json...
scp package.json root@31.97.129.5:/home/emailapp/site2/package.json 2>nul
scp backend/package.json root@31.97.129.5:/home/emailapp/site2/backend/package.json 2>nul

echo.
echo [2] בונה מחדש את site2...
echo ================================

ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm install && npm run build && cd backend && npm install && pm2 restart site2-backend && cd .. && pm2 restart site2-frontend"

echo.
echo [3] בודק סטטוס...
echo ================================

ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo ================================================
echo   ✅ השינויים הועלו ל-site2!
echo ================================================
echo.
echo התכונות החדשות זמינות ב:
echo http://31.97.129.5:8081
echo.
echo כולל:
echo - תוויות (labels) ליד כל מייל
echo - תרגום תוויות לעברית
echo - תמיכה ב-Gmail labels
echo.
pause