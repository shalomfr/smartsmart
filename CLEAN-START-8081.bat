@echo off
chcp 65001 >nul
cls
color 0B
echo ════════════════════════════════════════════════════
echo      התחלה נקייה - פורט 8081 + 4000
echo ════════════════════════════════════════════════════
echo.
echo זה ימחק את כל האתרים וייצור אחד חדש נקי!
echo.
echo לחץ Enter להמשך או Ctrl+C לביטול...
pause >nul

echo.
echo ► שלב 1: ניקוי מלא...
echo ═════════════════════
ssh root@31.97.129.5 "pm2 delete all 2>/dev/null || true"
ssh root@31.97.129.5 "killall node 2>/dev/null || true"
ssh root@31.97.129.5 "rm -rf /home/emailapp/site2 /home/emailapp/site3 /home/emailapp/site4 /home/emailapp/site-final"

echo.
echo ► שלב 2: יצירת אתר חדש...
echo ══════════════════════════
ssh root@31.97.129.5 "mkdir -p /home/emailapp/email-prod"

echo.
echo ► שלב 3: הכנת קבצים...
echo ═══════════════════════
REM תיקון AuthContext
powershell -Command "$content = Get-Content src\contexts\AuthContext.jsx -Raw; $content = $content -replace 'const API_URL = window\.location\.hostname === ''localhost''[^;]+;', 'const API_URL = ''http://31.97.129.5:4000/api'';'; Set-Content -Path src\contexts\AuthContext.jsx -Value $content"

REM תיקון API files
for %%f in (src\api\*.js) do (
    powershell -Command "(Get-Content %%f) -replace 'http://localhost:\d+', 'http://31.97.129.5:4000' | Set-Content %%f" 2>nul
)

REM תיקון Backend
powershell -Command "(Get-Content backend\server.js) -replace 'const PORT = \d+', 'const PORT = 4000' | Set-Content backend\server.js"

echo.
echo ► שלב 4: העלאה לשרת...
echo ═══════════════════════
echo מעלה Frontend...
scp -r src public package*.json vite.config.js index.html *.config.js components.json jsconfig.json root@31.97.129.5:/home/emailapp/email-prod/ 2>nul

echo מעלה Backend...
scp -r backend root@31.97.129.5:/home/emailapp/email-prod/

echo.
echo ► שלב 5: התקנה...
echo ═════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && npm install --legacy-peer-deps && cd backend && npm install"

echo.
echo ► שלב 6: בנייה...
echo ════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && npm run build"

echo.
echo ► שלב 7: הפעלה...
echo ════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && pm2 start server.js --name email-backend"
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && pm2 serve dist 8081 --name email-frontend --spa"

echo.
echo ► שלב 8: אימות...
echo ════════════════
ssh root@31.97.129.5 "sleep 3 && pm2 list"
echo.
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)'"

echo.
echo ════════════════════════════════════════════════════
echo              ✅ הושלם בהצלחה! ✅
echo ════════════════════════════════════════════════════
echo.
echo 🌐 כתובת האתר:
echo    http://31.97.129.5:8081
echo.
echo 🔑 כניסה למערכת:
echo    שם משתמש: admin
echo    סיסמה: 123456
echo.
echo 📋 מה יש במערכת:
echo    ✓ תיקיית "בהמתנה לתשובה"
echo    ✓ כפתור "צור טיוטה" סגול
echo    ✓ דף ניהול טיוטות מלא
echo.
echo ════════════════════════════════════════════════════
echo.
timeout /t 5 /nobreak
start http://31.97.129.5:8081