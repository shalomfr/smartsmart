@echo off
chcp 65001 >nul
cls
color 0B
echo ════════════════════════════════════════════════════
echo    תיקון מלא - בעיית API מחזיר HTML במקום JSON
echo ════════════════════════════════════════════════════
echo.
echo הבעיה: ה-Frontend מנסה לגשת ל-API דרך פורט 8082
echo        אבל שם רץ ה-Frontend עצמו!
echo.
echo הפתרון: לכוון את ה-Frontend ישירות לפורט 4000
echo.
echo ════════════════════════════════════════════════════
echo.
pause

echo.
echo ► שלב 1: בודק שה-Backend רץ על פורט 4000...
echo ═════════════════════════════════════════════
ssh root@31.97.129.5 "netstat -tlnp | grep 4000 && echo '✓ Backend רץ על פורט 4000'"

echo.
echo ► שלב 2: מתקן את כל ה-URLs בקבצים...
echo ══════════════════════════════════════

REM תיקון AuthContext
echo מתקן AuthContext.jsx...
powershell -Command "$content = Get-Content src\contexts\AuthContext.jsx -Raw; $content = $content -replace 'const API_URL = .*', '      const API_URL = ''http://31.97.129.5:4000/api'';'; $content = $content -replace 'fetch\(`\$\{API_URL\}/app/login`', 'fetch(''http://31.97.129.5:4000/api/app/login'''; Set-Content src\contexts\AuthContext.jsx $content"

REM תיקון API files
echo מתקן קבצי API...
for %%f in (src\api\*.js) do (
    powershell -Command "(Get-Content %%f) -replace 'const apiUrl = ''.*''', 'const apiUrl = ''http://31.97.129.5:4000''' -replace 'const API_URL = ''.*''', 'const API_URL = ''http://31.97.129.5:4000''' -replace 'http://localhost:\d+', 'http://31.97.129.5:4000' | Set-Content %%f" 2>nul
)

echo.
echo ► שלב 3: מעלה הכל לשרת...
echo ═══════════════════════════
scp -r src root@31.97.129.5:/home/emailapp/site2/

echo.
echo ► שלב 4: מוסיף CORS ל-Backend...
echo ═════════════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && sed -i 's/app.use(cors());/app.use(cors({ origin: [\"http:\/\/31.97.129.5:8082\", \"http:\/\/localhost:5173\"], credentials: true }));/' server.js"

echo.
echo ► שלב 5: בונה מחדש...
echo ══════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo ► שלב 6: מפעיל מחדש הכל...
echo ═══════════════════════════
ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend"

echo.
echo ► שלב 7: בדיקה סופית...
echo ════════════════════════
timeout /t 3 /nobreak >nul
echo.
echo בודק שה-API עובד:
ssh root@31.97.129.5 "curl -s -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -H 'Origin: http://31.97.129.5:8082' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"

echo.
echo ════════════════════════════════════════════════════
echo                ✅ סיימנו! ✅
echo ════════════════════════════════════════════════════
echo.
echo עכשיו:
echo 1. נקה מטמון דפדפן (Ctrl+F5)
echo 2. או פתח חלון גלישה פרטית
echo 3. היכנס ל: http://31.97.129.5:8082
echo.
echo כניסה:
echo   שם משתמש: admin
echo   סיסמה: 123456
echo.
echo ה-Frontend יפנה אוטומטית ל-Backend על פורט 4000
echo.
echo ════════════════════════════════════════════════════
echo.
pause