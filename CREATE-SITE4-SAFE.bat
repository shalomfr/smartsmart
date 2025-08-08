@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *      יצירת אתר חדש - site4                      *
echo *      Frontend: פורט 7000 (בטוח פנוי)            *
echo *      Backend: פורט 7001 (בטוח פנוי)             *
echo ****************************************************
echo.

echo [1] עוצר ומוחק site3 שלא עובד...
echo ==================================
ssh root@31.97.129.5 "pm2 delete site3-backend site3-frontend 2>/dev/null || true"
ssh root@31.97.129.5 "rm -rf /home/emailapp/site3"

echo.
echo [2] יוצר תיקיה חדשה site4...
echo ==============================
ssh root@31.97.129.5 "mkdir -p /home/emailapp/site4"

echo.
echo [3] מעדכן קבצים מקומיים לפורטים החדשים...
echo ============================================
echo מעדכן AuthContext...
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace 'http://31.97.129.5:\d+', 'http://31.97.129.5:7001' -replace 'localhost:\d+', 'localhost:7001' | Set-Content src\contexts\AuthContext.jsx"

echo.
echo מעדכן קבצי API...
for %%f in (src\api\*.js) do (
    powershell -Command "(Get-Content %%f) -replace 'http://localhost:\d+', 'http://31.97.129.5:7001' -replace 'http://31.97.129.5:\d+', 'http://31.97.129.5:7001' | Set-Content %%f" 2>nul
)

echo.
echo מעדכן Backend port...
powershell -Command "(Get-Content backend\server.js) -replace 'const PORT = \d+', 'const PORT = 7001' | Set-Content backend\server.js"

echo.
echo [4] מעלה קבצים לשרת...
echo ========================
echo מעלה Frontend...
scp -r src public package*.json vite.config.js index.html tailwind.config.js postcss.config.js components.json jsconfig.json eslint.config.js root@31.97.129.5:/home/emailapp/site4/ 2>nul

echo.
echo מעלה Backend...
scp -r backend root@31.97.129.5:/home/emailapp/site4/

echo.
echo [5] מתקין תלויות...
echo ===================
ssh root@31.97.129.5 "cd /home/emailapp/site4 && npm install --silent"
ssh root@31.97.129.5 "cd /home/emailapp/site4/backend && npm install --silent"

echo.
echo [6] בונה את הפרויקט...
echo =======================
ssh root@31.97.129.5 "cd /home/emailapp/site4 && npm run build"

echo.
echo [7] מפעיל עם PM2 - ספציפית על הפורטים שלנו...
echo ==============================================
ssh root@31.97.129.5 "cd /home/emailapp/site4/backend && PORT=7001 pm2 start server.js --name site4-backend"
ssh root@31.97.129.5 "cd /home/emailapp/site4 && pm2 serve dist 7000 --name site4-frontend --spa"

echo.
echo [8] פותח פורטים בחומת אש...
echo ============================
ssh root@31.97.129.5 "ufw allow 7000/tcp && ufw allow 7001/tcp && ufw reload"

echo.
echo [9] בודק שהכל רץ...
echo ===================
ssh root@31.97.129.5 "sleep 3"
ssh root@31.97.129.5 "pm2 list | grep site4"
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(7000|7001)'"

echo.
echo ****************************************************
echo *               סיימנו! 🎉                        *
echo ****************************************************
echo.
echo האתר החדש זמין ב:
echo http://31.97.129.5:7000
echo.
echo כניסה עם:
echo שם משתמש: admin
echo סיסמה: 123456
echo.
echo Backend API: http://31.97.129.5:7001
echo.
echo ****************************************************
echo.
pause

start http://31.97.129.5:7000