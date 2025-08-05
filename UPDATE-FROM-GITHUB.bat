@echo off
echo ===== מעדכן דרך GitHub =====
echo.

echo [1] דוחף שינויים ל-GitHub...
git add .
git commit -m "Fix CORS and auth issues"
git push -u origin main --force

echo.
echo [2] מושך את השינויים בשרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull origin main"

echo.
echo [3] בונה מחדש...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && npm install && npm run build"

echo.
echo [4] מעדכן Backend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && npm install"

echo.
echo [5] מפעיל מחדש הכל...
ssh root@31.97.129.5 "pm2 restart all"

echo.
echo [6] מתקן Nginx אם צריך...
ssh root@31.97.129.5 "systemctl restart nginx"

echo.
echo [7] בדיקה סופית...
ssh root@31.97.129.5 "pm2 status && netstat -tlnp | grep :80"

echo.
echo ===== הושלם! =====
echo נסה עכשיו:
echo - http://31.97.129.5
echo - http://31.97.129.5:8080
echo.
echo משתמש: admin
echo סיסמה: 123456
echo.
pause