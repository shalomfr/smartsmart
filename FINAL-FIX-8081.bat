@echo off
chcp 65001 >nul
cls
color 0B
echo ════════════════════════════════════════════════════
echo           תיקון סופי למערכת על 8081
echo ════════════════════════════════════════════════════
echo.

echo ► שלב 1: תיקון Backend Port...
echo ══════════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && sed -i 's/const PORT = .*/const PORT = 4000;/' server.js"
ssh root@31.97.129.5 "pm2 delete email-backend 2>/dev/null"
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && pm2 start server.js --name email-backend -- --port 4000"

echo.
echo ► שלב 2: העלאת קבצי API חסרים...
echo ═════════════════════════════════
scp -r src/api root@31.97.129.5:/home/emailapp/email-prod/src/

echo.
echo ► שלב 3: תיקון URLs בכל הקבצים...
echo ══════════════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/src/api && for f in *.js; do sed -i 's|const API_URL = .*|const API_URL = '\''http://31.97.129.5:4000'\'';|' \$f; sed -i 's|const apiUrl = .*|const apiUrl = '\''http://31.97.129.5:4000'\'';|' \$f; done"

echo.
echo ► שלב 4: תיקון export ב-realEmailAPI...
echo ════════════════════════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/src/api && grep -q 'export const realEmailAPI' realEmailAPI.js || echo 'export const realEmailAPI = Account;' >> realEmailAPI.js"

echo.
echo ► שלב 5: בנייה מחדש...
echo ═══════════════════════
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && npm run build"

echo.
echo ► שלב 6: הפעלה מחדש...
echo ═══════════════════════
ssh root@31.97.129.5 "pm2 restart email-backend email-frontend"

echo.
echo ► שלב 7: המתנה ובדיקה...
echo ═════════════════════════
timeout /t 5 /nobreak >nul
echo.
echo בודק פורטים:
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)'"
echo.
echo בודק API:
ssh root@31.97.129.5 "curl -s http://localhost:4000/api/app/login -X POST -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"

echo.
echo ════════════════════════════════════════════════════
echo              ✅ הכל מוכן! ✅
echo ════════════════════════════════════════════════════
echo.
echo 🌐 האתר: http://31.97.129.5:8081
echo.
echo 🔑 כניסה:
echo    שם משתמש: admin
echo    סיסמה: 123456
echo.
echo 💡 טיפ: נקה מטמון (Ctrl+F5) לפני הניסיון
echo.
echo ════════════════════════════════════════════════════
echo.
pause