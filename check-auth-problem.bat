@echo off
echo ===== בדיקת בעיית אימות =====
echo.

echo [1] בודק אם ה-API עובד...
curl -X POST http://31.97.129.5/api/app/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"123456\"}"
echo.
echo.

echo [2] בודק Nginx logs...
ssh root@31.97.129.5 "tail -10 /var/log/nginx/error.log"
echo.

echo [3] בודק Backend logs...
ssh root@31.97.129.5 "pm2 logs backend --lines 20"
echo.

echo ===== טיפים =====
echo.
echo אם אתה רואה 401 Unauthorized:
echo 1. נקה cookies ו-cache
echo 2. נסה בדפדפן אחר או במצב גלישה בסתר
echo 3. הרץ: fix-auth-issue.bat
echo.
pause