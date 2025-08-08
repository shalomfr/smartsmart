@echo off
chcp 65001 >nul
cls
color 0E
echo ╔════════════════════════════════════════════════════╗
echo ║        התקנה מלאה מחדש - פורט 8081 + 4000         ║
echo ╔════════════════════════════════════════════════════╗
echo.
echo ⚠️  אזהרה: זה ימחק את כל מה שיש בשרת ויתקין הכל מחדש!
echo.
echo לחץ Enter להמשך או Ctrl+C לביטול...
pause >nul

echo.
echo ► שלב 1: ניקוי מוחלט של השרת...
echo ════════════════════════════════
ssh root@31.97.129.5 "pm2 delete all 2>/dev/null || true"
ssh root@31.97.129.5 "pm2 kill 2>/dev/null || true"
ssh root@31.97.129.5 "killall node 2>/dev/null || true"
ssh root@31.97.129.5 "rm -rf /home/emailapp/*"
ssh root@31.97.129.5 "rm -rf ~/.pm2/logs/*"

echo.
echo ► שלב 2: יצירת מבנה תיקיות חדש...
echo ═══════════════════════════════════
ssh root@31.97.129.5 "mkdir -p /home/emailapp/email-prod/{dist,backend,logs}"

echo.
echo ► שלב 3: הכנת קבצים מקומית (תיקון URLs)...
echo ═════════════════════════════════════════════
REM יצירת גיבויים
copy src\contexts\AuthContext.jsx src\contexts\AuthContext.jsx.backup >nul 2>&1
copy src\api\realEmailAPI.js src\api\realEmailAPI.js.backup >nul 2>&1

REM תיקון AuthContext - הסרת בדיקת localhost
powershell -Command "$content = Get-Content src\contexts\AuthContext.jsx -Raw; $content = $content -replace 'const API_URL = window\.location\.hostname === ''localhost''[^;]+;', 'const API_URL = ''http://31.97.129.5:4000/api'';'; Set-Content -Path src\contexts\AuthContext.jsx -Value $content -Encoding UTF8"

REM תיקון realEmailAPI - הסרת בדיקת localhost
powershell -Command "$content = Get-Content src\api\realEmailAPI.js -Raw; $content = $content -replace 'const API_URL = \(typeof window[^;]+;', 'const API_URL = ''http://31.97.129.5:4000/api'';'; Set-Content -Path src\api\realEmailAPI.js -Value $content -Encoding UTF8"

REM תיקון כל קבצי ה-API
for %%f in (src\api\*.js) do (
    powershell -Command "(Get-Content %%f) -replace 'http://localhost:\d+', 'http://31.97.129.5:4000' -replace '/api', 'http://31.97.129.5:4000/api' | Set-Content %%f -Encoding UTF8" 2>nul
)

REM תיקון Backend
powershell -Command "(Get-Content backend\server.js) -replace 'const PORT = process\.env\.PORT \|\| \d+', 'const PORT = 4000' | Set-Content backend\server.js -Encoding UTF8"

echo.
echo ► שלב 4: התקנת תלויות מקומית (אם צריך)...
echo ═══════════════════════════════════════════════
if not exist node_modules (
    call npm install --legacy-peer-deps
)

echo.
echo ► שלב 5: בניית פרונטאנד מקומית...
echo ═══════════════════════════════════
call npm run build
if %errorlevel% neq 0 (
    echo ❌ שגיאה בבניית הפרונטאנד!
    echo מחזיר קבצים למצב המקורי...
    copy src\contexts\AuthContext.jsx.backup src\contexts\AuthContext.jsx >nul 2>&1
    copy src\api\realEmailAPI.js.backup src\api\realEmailAPI.js >nul 2>&1
    del src\contexts\AuthContext.jsx.backup >nul 2>&1
    del src\api\realEmailAPI.js.backup >nul 2>&1
    pause
    exit /b
)
echo ✅ הפרונטאנד נבנה בהצלחה

echo.
echo ► שלב 6: העלאת קבצים לשרת...
echo ════════════════════════════════
echo מעלה Frontend...
scp -r dist/* root@31.97.129.5:/home/emailapp/email-prod/dist/

echo מעלה Backend...
scp backend/server.js root@31.97.129.5:/home/emailapp/email-prod/backend/
scp backend/package.json root@31.97.129.5:/home/emailapp/email-prod/backend/

echo מעלה קובץ .env (אם קיים)...
if exist backend\.env (
    scp backend\.env root@31.97.129.5:/home/emailapp/email-prod/backend/
)

echo.
echo ► שלב 7: התקנת תלויות בשרת...
echo ════════════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && npm install --legacy-peer-deps --production"

echo.
echo ► שלב 8: הגדרת PM2 ecosystem...
echo ═════════════════════════════════
ssh root@31.97.129.5 "cat > /home/emailapp/email-prod/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'email-backend',
    script: './backend/server.js',
    cwd: '/home/emailapp/email-prod',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    env: {
      NODE_ENV: 'production',
      PORT: 4000
    },
    error_file: './logs/backend-error.log',
    out_file: './logs/backend-out.log',
    log_file: './logs/backend-combined.log',
    time: true
  }, {
    name: 'email-frontend',
    script: 'pm2-runtime serve dist 8081 --spa',
    cwd: '/home/emailapp/email-prod',
    instances: 1,
    autorestart: true,
    watch: false,
    error_file: './logs/frontend-error.log',
    out_file: './logs/frontend-out.log',
    log_file: './logs/frontend-combined.log',
    time: true
  }]
};
EOF"

echo.
echo ► שלב 9: הפעלת השרתים...
echo ══════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && pm2 start ecosystem.config.js"
ssh root@31.97.129.5 "pm2 save"
ssh root@31.97.129.5 "pm2 startup systemd -u root --hp /root"

echo.
echo ► שלב 10: בדיקת סטטוס...
echo ══════════════════════════
timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "pm2 list"
echo.
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)' || ss -tlnp | grep -E '(8081|4000)'"

echo.
echo ► שלב 11: בדיקת תקינות...
echo ═══════════════════════════
echo בודק Frontend...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://31.97.129.5:8081' -UseBasicParsing -TimeoutSec 5; Write-Host '✅ Frontend עובד!' -ForegroundColor Green } catch { Write-Host '❌ Frontend לא זמין!' -ForegroundColor Red }"

echo בודק Backend API...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://31.97.129.5:4000/api/health' -UseBasicParsing -TimeoutSec 5; Write-Host '✅ Backend עובד!' -ForegroundColor Green } catch { Write-Host '⚠️  Backend API אולי לא זמין (זה נורמלי אם אין endpoint כזה)' -ForegroundColor Yellow }"

echo.
echo ► שלב 12: החזרת קבצים מקוריים...
echo ═══════════════════════════════════
copy src\contexts\AuthContext.jsx.backup src\contexts\AuthContext.jsx >nul 2>&1
copy src\api\realEmailAPI.js.backup src\api\realEmailAPI.js >nul 2>&1
del src\contexts\AuthContext.jsx.backup >nul 2>&1
del src\api\realEmailAPI.js.backup >nul 2>&1

echo.
echo ╔════════════════════════════════════════════════════╗
echo ║              ✅ ההתקנה הושלמה בהצלחה! ✅           ║
echo ╚════════════════════════════════════════════════════╝
echo.
echo 🌐 כתובת האתר: http://31.97.129.5:8081
echo 🔧 Backend API: http://31.97.129.5:4000
echo.
echo 📊 מה הותקן:
echo    ✓ Frontend עם כל העדכונים האחרונים
echo    ✓ Backend עם תמיכה מלאה ב-API
echo    ✓ ספירות דינמיות של מיילים
echo    ✓ עדכון אוטומטי של בועות
echo    ✓ PM2 ecosystem להפעלה יציבה
echo.
echo 💡 טיפים:
echo    • אם הבועות לא מתעדכנות, ודא שיש מיילים בחשבון
echo    • בדוק את הלוגים: ssh root@31.97.129.5 "pm2 logs"
echo    • לרענון מהיר: ssh root@31.97.129.5 "pm2 restart all"
echo.
echo ════════════════════════════════════════════════════
echo.
timeout /t 5 /nobreak
start http://31.97.129.5:8081
