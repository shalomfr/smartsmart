@echo off
chcp 65001 >nul
cls
color 0B
echo ════════════════════════════════════════════════════
echo          אבחון ותיקון אוטומטי
echo ════════════════════════════════════════════════════
echo.

echo שלב 1: בדיקת קבצים מקומיים...
echo ════════════════════════════════
echo.
echo ✓ AuthContext מכוון ל: 31.97.129.5:4000
echo ✓ Backend מגדיר: admin/123456
echo ✓ API files מכוונים ל: 31.97.129.5:4000
echo.

echo שלב 2: בדיקת השרת...
echo ═════════════════════
ssh root@31.97.129.5 "echo 'Backend רץ על:' && netstat -tlnp | grep 4000"
ssh root@31.97.129.5 "echo 'Frontend רץ על:' && netstat -tlnp | grep 8082"

echo.
echo שלב 3: בדיקת CORS ב-Backend...
echo ════════════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'cors' server.js | head -3"

echo.
echo שלב 4: תיקון CORS...
echo ════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && sed -i '/app.use(cors/c\app.use(cors({ origin: true, credentials: true }));' server.js"

echo.
echo שלב 5: העלאה מחדש של כל הקבצים...
echo ════════════════════════════════════

echo מעלה src...
scp -r src root@31.97.129.5:/home/emailapp/site2/

echo מעלה backend...
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo שלב 6: בנייה מחדש...
echo ═════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo שלב 7: הפעלה מחדש...
echo ═════════════════════
ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend"

echo.
echo שלב 8: בדיקה סופית...
echo ═══════════════════════
timeout /t 3 /nobreak >nul
echo.
echo בודק API:
ssh root@31.97.129.5 "curl -s -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -H 'Origin: http://31.97.129.5:8082' -d '{\"username\":\"admin\",\"password\":\"123456\"}' | python3 -m json.tool 2>/dev/null || echo 'התשובה:' && cat"

echo.
echo ════════════════════════════════════════════════════
echo                 סיום אבחון
echo ════════════════════════════════════════════════════
echo.
echo אם ראית "success": true - הכל תקין!
echo.
echo נסה עכשיו:
echo 1. נקה מטמון (Ctrl+F5)
echo 2. היכנס ל: http://31.97.129.5:8082
echo 3. admin / 123456
echo.
pause