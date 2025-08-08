@echo off
chcp 65001 >nul
echo ================================================
echo         בנייה והפעלה מחדש של site2
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root
set REMOTE_PATH=/home/emailapp/site2

echo [1] בונה את האפליקציה...
echo.
ssh %USER%@%SERVER% "cd %REMOTE_PATH% && npm run build"

echo.
echo [2] מפעיל מחדש את השרתים...
echo.
ssh %USER%@%SERVER% "pm2 restart site2-backend && pm2 restart site2-frontend"

echo.
echo [3] בודק סטטוס...
echo.
ssh %USER%@%SERVER% "pm2 status"

echo.
echo ================================================
echo              ✓ הושלם!
echo ================================================
echo.
echo האתר אמור לעבוד עכשיו ב:
echo http://31.97.129.5:8081
echo.
echo אם יש שגיאות, בדוק את הלוגים:
echo pm2 logs site2-backend
echo pm2 logs site2-frontend
echo.
pause