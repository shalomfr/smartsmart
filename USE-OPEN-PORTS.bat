@echo off
chcp 65001 >nul
cls
color 0B
echo ****************************************************
echo *    שימוש בפורטים פתוחים - הפתרון הטוב ביותר    *
echo *    Frontend: 9000 (פתוח בחומת אש)              *
echo *    Backend: 3000 (אם פנוי)                      *
echo ****************************************************
echo.

echo [1] בודק אם הפורטים פנויים...
echo ================================
ssh root@31.97.129.5 "netstat -tlnp | grep -E ':(9000|3000)' || echo 'הפורטים פנויים!'"

echo.
echo [2] מנקה התקנות קודמות...
echo ==========================
ssh root@31.97.129.5 "pm2 delete site3-backend site3-frontend site4-backend site4-frontend 2>/dev/null || true"
ssh root@31.97.129.5 "rm -rf /home/emailapp/site3 /home/emailapp/site4"

echo.
echo [3] יוצר site-final...
echo ======================
ssh root@31.97.129.5 "mkdir -p /home/emailapp/site-final"

echo.
echo [4] מעדכן קבצים לפורטים הנכונים...
echo ====================================
echo מעדכן AuthContext ל-3000...
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace 'http://[^:]+:\d+/api', 'http://31.97.129.5:3000/api' -replace 'localhost:\d+/api', 'localhost:3000/api' | Set-Content src\contexts\AuthContext.jsx"

echo מעדכן API files...
for %%f in (src\api\*.js) do (
    powershell -Command "(Get-Content %%f) -replace 'http://[^:]+:\d+', 'http://31.97.129.5:3000' | Set-Content %%f" 2>nul
)

echo מעדכן Backend ל-3000...
powershell -Command "(Get-Content backend\server.js) -replace 'const PORT = \d+', 'const PORT = 3000' | Set-Content backend\server.js"

echo.
echo [5] מעלה הכל לשרת...
echo =====================
scp -r src public package*.json vite.config.js index.html *.config.js components.json jsconfig.json root@31.97.129.5:/home/emailapp/site-final/ 2>nul
scp -r backend root@31.97.129.5:/home/emailapp/site-final/

echo.
echo [6] מתקין ובונה...
echo ==================
ssh root@31.97.129.5 "cd /home/emailapp/site-final && npm install --legacy-peer-deps"
ssh root@31.97.129.5 "cd /home/emailapp/site-final/backend && npm install"
ssh root@31.97.129.5 "cd /home/emailapp/site-final && npm run build"

echo.
echo [7] מפעיל על הפורטים הנכונים...
echo ================================
ssh root@31.97.129.5 "cd /home/emailapp/site-final/backend && PORT=3000 pm2 start server.js --name final-backend -- --port 3000"
ssh root@31.97.129.5 "cd /home/emailapp/site-final && pm2 serve dist 9000 --name final-frontend --spa"

echo.
echo [8] בודק שהכל רץ...
echo ===================
ssh root@31.97.129.5 "sleep 3 && pm2 list | grep final"
ssh root@31.97.129.5 "netstat -tlnp | grep -E ':(9000|3000)'"

echo.
echo ****************************************************
echo *           🎉 הצלחנו סוף סוף! 🎉                 *
echo ****************************************************
echo.
echo 🌐 האתר שלך:
echo    http://31.97.129.5:9000
echo.
echo 🔐 כניסה:
echo    שם משתמש: admin
echo    סיסמה: 123456
echo.
echo 📡 Backend API: http://31.97.129.5:3000
echo.
echo ****************************************************
echo.
pause

start http://31.97.129.5:9000