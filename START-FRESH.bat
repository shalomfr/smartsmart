@echo off
chcp 65001 >nul
cls
color 0B
echo ════════════════════════════════════════════════════
echo       🚀 התחלה חדשה - פתרון מלא 🚀
echo ════════════════════════════════════════════════════
echo.
echo תוכנית זו תיצור אתר חדש לגמרי:
echo.
echo 📍 Frontend: http://31.97.129.5:5173
echo 📍 Backend: http://31.97.129.5:5000
echo 👤 כניסה: admin / 123456
echo.
echo ════════════════════════════════════════════════════
echo.
echo לחץ Enter להתחיל (או Ctrl+C לביטול)...
pause >nul

cls
echo ► מתחילים...
echo.

REM תיקון AuthContext
echo [1/6] מתקן קובץ AuthContext...
echo ==============================
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace 'const API_URL = .*', '      const API_URL = ''http://31.97.129.5:5000/api'';' -replace ': ''http://.*:4000/api'';', ': ''http://31.97.129.5:5000/api'';' | Set-Content src\contexts\AuthContext.jsx"

REM תיקון קבצי API
echo.
echo [2/6] מתקן קבצי API...
echo ======================
for %%f in (src\api\*.js) do (
    echo מעדכן %%f...
    powershell -Command "(Get-Content %%f) -replace 'http://localhost:4000', 'http://31.97.129.5:5000' -replace 'http://localhost:3001', 'http://31.97.129.5:5000' | Set-Content %%f"
)

REM תיקון Backend port
echo.
echo [3/6] מתקן Backend port...
echo ==========================
powershell -Command "(Get-Content backend\server.js) -replace 'const PORT = \d+', 'const PORT = 5000' | Set-Content backend\server.js"

REM העלאה לשרת
echo.
echo [4/6] מעלה לשרת...
echo ===================
ssh root@31.97.129.5 "pm2 delete site3-backend site3-frontend 2>/dev/null || true"
ssh root@31.97.129.5 "rm -rf /home/emailapp/site3 && mkdir -p /home/emailapp/site3"

echo מעלה Frontend...
scp -r src public package*.json vite.config.js index.html tailwind.config.js postcss.config.js components.json jsconfig.json root@31.97.129.5:/home/emailapp/site3/ 2>nul

echo מעלה Backend...
scp -r backend root@31.97.129.5:/home/emailapp/site3/

REM התקנה ובנייה
echo.
echo [5/6] מתקין ובונה...
echo ====================
ssh root@31.97.129.5 "cd /home/emailapp/site3 && npm install --silent"
ssh root@31.97.129.5 "cd /home/emailapp/site3/backend && npm install --silent"
ssh root@31.97.129.5 "cd /home/emailapp/site3 && npm run build"

REM הפעלה
echo.
echo [6/6] מפעיל את האתר...
echo =======================
ssh root@31.97.129.5 "cd /home/emailapp/site3/backend && pm2 start server.js --name site3-backend"
ssh root@31.97.129.5 "cd /home/emailapp/site3 && pm2 serve dist 5173 --name site3-frontend --spa"
ssh root@31.97.129.5 "ufw allow 5173/tcp && ufw allow 5000/tcp && ufw reload"

echo.
echo ════════════════════════════════════════════════════
echo           ✅ הושלם בהצלחה! ✅
echo ════════════════════════════════════════════════════
echo.
echo 🌐 האתר שלך מוכן:
echo    http://31.97.129.5:5173
echo.
echo 🔐 כניסה:
echo    שם משתמש: admin
echo    סיסמה: 123456
echo.
echo 📋 תכונות:
echo    ✓ בהמתנה לתשובה
echo    ✓ כפתור צור טיוטה
echo    ✓ ניהול טיוטות מלא
echo.
echo ════════════════════════════════════════════════════
echo.
timeout /t 3 >nul
start http://31.97.129.5:5173