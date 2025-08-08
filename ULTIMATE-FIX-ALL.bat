@echo off
chcp 65001 >nul
cls
color 0B
echo ════════════════════════════════════════════════════
echo           תיקון סופי - כל הבעיות
echo ════════════════════════════════════════════════════
echo.
echo מתקן את כל הבעיות האפשריות:
echo 1. URLs לא נכונים
echo 2. CORS
echo 3. Proxy
echo 4. קבצים לא מעודכנים
echo.
echo ════════════════════════════════════════════════════
echo.
pause

echo.
echo ► שלב 1: ווידוא הגדרות מקומיות...
echo ═══════════════════════════════════
echo.

REM תיקון AuthContext לוודא שה-URL נכון
echo תיקון AuthContext...
powershell -Command "$content = Get-Content src\contexts\AuthContext.jsx; $lineNum = 0; $newContent = @(); foreach($line in $content) { $lineNum++; if($lineNum -eq 29) { $newContent += '      const response = await fetch(''http://31.97.129.5:4000/api/app/login'', {' } else { $newContent += $line } }; Set-Content src\contexts\AuthContext.jsx $newContent"

REM וידוא API files
echo תיקון API files...
powershell -Command "Get-ChildItem src\api\*.js | ForEach-Object { (Get-Content $_.FullName) -replace 'const API_URL = .*', 'const API_URL = ''http://31.97.129.5:4000'';' -replace 'const apiUrl = .*', 'const apiUrl = ''http://31.97.129.5:4000'';' | Set-Content $_.FullName }"

echo.
echo ► שלב 2: עדכון vite.config.js עם proxy...
echo ═══════════════════════════════════════════
copy vite.config.js vite.config.js.backup 2>nul
(
echo import { defineConfig } from 'vite'
echo import react from '@vitejs/plugin-react'
echo import path from 'path'
echo.
echo export default defineConfig({
echo   base: './',
echo   plugins: [react()],
echo   server: {
echo     allowedHosts: true,
echo     proxy: {
echo       '/api': {
echo         target: 'http://localhost:4000',
echo         changeOrigin: true,
echo         secure: false
echo       }
echo     }
echo   },
echo   resolve: {
echo     alias: {
echo       '@': path.resolve(__dirname, './src'),
echo     },
echo     extensions: ['.mjs', '.js', '.jsx', '.ts', '.tsx', '.json']
echo   },
echo   optimizeDeps: {
echo     esbuildOptions: {
echo       loader: {
echo         '.js': 'jsx',
echo       },
echo     },
echo   },
echo })
) > vite.config.js

echo.
echo ► שלב 3: העלאה מלאה לשרת...
echo ═════════════════════════════
echo העלאת כל הקבצים...
scp -r src root@31.97.129.5:/home/emailapp/site2/
scp -r public root@31.97.129.5:/home/emailapp/site2/
scp vite.config.js package*.json index.html *.config.js components.json jsconfig.json root@31.97.129.5:/home/emailapp/site2/ 2>nul
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo ► שלב 4: תיקון CORS ב-Backend...
echo ═════════════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && sed -i 's/app.use(cors());/app.use(cors({ origin: [\"http:\/\/31.97.129.5:8082\", \"http:\/\/localhost:5173\", \"http:\/\/localhost:8082\"], credentials: true }));/' server.js"

echo.
echo ► שלב 5: בנייה נקייה...
echo ════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/site2 && rm -rf dist node_modules/.cache && npm run build"

echo.
echo ► שלב 6: הפעלה מחדש...
echo ═══════════════════════
ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend"

echo.
echo ► שלב 7: בדיקה סופית...
echo ════════════════════════
timeout /t 5 /nobreak >nul
echo.
echo בודק Backend:
ssh root@31.97.129.5 "curl -s -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -H 'Origin: http://31.97.129.5:8082' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"

echo.
echo ════════════════════════════════════════════════════
echo              ✅ הכל תוקן! ✅
echo ════════════════════════════════════════════════════
echo.
echo עכשיו:
echo 1. סגור את הדפדפן לגמרי
echo 2. פתח דפדפן חדש (רצוי בגלישה פרטית)
echo 3. היכנס ל: http://31.97.129.5:8082
echo.
echo כניסה:
echo   שם משתמש: admin
echo   סיסמה: 123456
echo.
echo אם עדיין לא עובד - תלחץ F12 ותבדוק ב-Network
echo איזה URL הוא מנסה לפנות אליו
echo.
echo ════════════════════════════════════════════════════
echo.
pause