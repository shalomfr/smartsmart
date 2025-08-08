@echo off
chcp 65001 >nul
cls
color 0A
echo ════════════════════════════════════════════════════
echo         פריסה פשוטה ומהירה - פורט 8081 + 4000
echo ════════════════════════════════════════════════════
echo.

echo ► שלב 1: בדיקת מצב נוכחי...
echo ═════════════════════════════
ssh root@31.97.129.5 "pm2 list"
echo.

echo ► שלב 2: עצירת תהליכים קיימים...
echo ═══════════════════════════════════
ssh root@31.97.129.5 "pm2 delete email-backend email-frontend 2>/dev/null || true"

echo.
echo ► שלב 3: הכנת קבצים מקומית...
echo ════════════════════════════════
REM תיקון URLs
powershell -Command "$content = Get-Content src\contexts\AuthContext.jsx -Raw; $content = $content -replace 'const API_URL = window\.location\.hostname === ''localhost''[^;]+;', 'const API_URL = ''http://31.97.129.5:4000/api'';'; Set-Content -Path src\contexts\AuthContext.jsx -Value $content"

echo.
echo ► שלב 4: בניית Frontend...
echo ══════════════════════════
call npm run build
if %errorlevel% neq 0 (
    echo ❌ שגיאה בבנייה!
    pause
    exit /b
)

echo.
echo ► שלב 5: העלאת קבצים...
echo ═════════════════════════
echo מעלה Frontend...
scp -r dist/* root@31.97.129.5:/home/emailapp/email-prod/dist/

echo מעלה Backend...
scp backend/server.js root@31.97.129.5:/home/emailapp/email-prod/backend/
scp backend/package.json root@31.97.129.5:/home/emailapp/email-prod/backend/

echo.
echo ► שלב 6: התקנת תלויות Backend...
echo ═════════════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && npm install --production"

echo.
echo ► שלב 7: הפעלת שרתים...
echo ═════════════════════════
echo מפעיל Backend...
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && pm2 start server.js --name email-backend -- --port 4000"

echo מפעיל Frontend...
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && pm2 serve dist 8081 --name email-frontend --spa"

echo.
echo ► שלב 8: שמירת הגדרות...
echo ══════════════════════════
ssh root@31.97.129.5 "pm2 save"

echo.
echo ► שלב 9: בדיקת סטטוס...
echo ═════════════════════════
timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "pm2 list"
echo.
ssh root@31.97.129.5 "netstat -tlnp | grep -E '8081|4000'"

echo.
echo ════════════════════════════════════════════════════
echo              ✅ הפריסה הושלמה! ✅
echo ════════════════════════════════════════════════════
echo.
echo 🌐 האתר זמין ב: http://31.97.129.5:8081
echo.
echo 💡 לבדיקת לוגים: ssh root@31.97.129.5 "pm2 logs"
echo.
pause
start http://31.97.129.5:8081
