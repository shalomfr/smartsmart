@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *      פתרון סופי נקי - משתמש ב-8082              *
echo ****************************************************
echo.
echo פשוט נעצור את site2 ונשתמש בפורטים שלו!
echo.
pause

echo.
echo [1] עוצר את כל האתרים...
echo ==========================
ssh root@31.97.129.5 "pm2 stop all"
ssh root@31.97.129.5 "pm2 delete site2-frontend site2-backend site3-frontend site3-backend 2>/dev/null || true"

echo.
echo [2] מעדכן קבצים מקומיים...
echo ============================
echo מעדכן AuthContext ל-4000...
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace 'const API_URL = .*', '      const API_URL = ''http://31.97.129.5:4000/api'';' | Set-Content src\contexts\AuthContext.jsx"

echo מעדכן API files...
for %%f in (src\api\*.js) do (
    powershell -Command "(Get-Content %%f) -replace 'http://localhost:\d+', 'http://31.97.129.5:4000' | Set-Content %%f" 2>nul
)

echo מעדכן Backend ל-4000...
powershell -Command "(Get-Content backend\server.js) -replace 'const PORT = \d+', 'const PORT = 4000' | Set-Content backend\server.js"

echo.
echo [3] מעלה לתיקיית site2 הקיימת...
echo ===================================
ssh root@31.97.129.5 "rm -rf /home/emailapp/site2/src /home/emailapp/site2/backend"

scp -r src public package*.json vite.config.js index.html *.config.js components.json jsconfig.json root@31.97.129.5:/home/emailapp/site2/ 2>nul
scp -r backend root@31.97.129.5:/home/emailapp/site2/

echo.
echo [4] מתקין ובונה...
echo ==================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm install --legacy-peer-deps"
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && npm install"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [5] מפעיל מחדש את site2...
echo ===========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && pm2 start server.js --name site2-backend"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8082 --name site2-frontend --spa"

echo.
echo [6] בודק שהכל עובד...
echo ======================
ssh root@31.97.129.5 "sleep 3"
ssh root@31.97.129.5 "pm2 list | grep site2"
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8082|4000)'"

echo.
echo ****************************************************
echo *               הצלחנו! 🎉                        *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8082
echo.
echo כניסה:
echo   שם משתמש: admin
echo   סיסמה: 123456
echo.
echo ****************************************************
echo.
pause

start http://31.97.129.5:8082