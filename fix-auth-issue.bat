@echo off
echo ===== מתקן בעיית אימות =====
echo.

echo [1] מעדכן קוד...
git add . && git commit -m "Fix CORS for login" && git push --force

echo.
echo [2] מעדכן שרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && cd backend && pm2 restart backend"

echo.
echo [3] בודק סטטוס...
ssh root@31.97.129.5 "pm2 status"

echo.
echo ===== הושלם! =====
echo.
echo 1. נקה את המטמון בדפדפן (Ctrl+Shift+Delete)
echo 2. נסה במצב גלישה בסתר (Ctrl+Shift+N)
echo 3. גש ל: http://31.97.129.5
echo.
echo משתמש: admin
echo סיסמה: 123456
echo.
pause