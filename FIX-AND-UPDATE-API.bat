@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *    תיקון מלא - Frontend + API URLs              *
echo ****************************************************
echo.

echo [1] בודק API URL בקוד...
echo ========================
type src\api\settingsAPI.js | findstr "apiUrl"

echo.
echo [2] מעדכן API URL אם צריך...
echo =============================
powershell -Command "(Get-Content src\api\settingsAPI.js) -replace 'http://localhost:4000', 'http://31.97.129.5:4000' | Set-Content src\api\settingsAPI.js"

echo.
echo [3] מעלה קובץ מעודכן...
echo =======================
scp src/api/settingsAPI.js root@31.97.129.5:/home/emailapp/site2/src/api/

echo.
echo [4] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [5] מפעיל על פורט 8082...
echo ==========================
ssh root@31.97.129.5 "pm2 delete site2-frontend 2>/dev/null || true"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8082 --name site2-frontend --spa"
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [6] סטטוס סופי...
echo =================
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo ****************************************************
echo *                 סיימנו!                          *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8082
echo.
echo כניסה:
echo   אימייל: admin@example.com
echo   סיסמה: admin123
echo.
pause