@echo off
REM ===== התיקון הסופי - פשוט הרץ אותי! =====

echo.
echo ==================================
echo    מתקן הכל ב-3 שלבים פשוטים
echo ==================================
echo.

echo [1/3] מעדכן GitHub...
git add . >nul 2>&1
git commit -m "Update" >nul 2>&1
git push --force >nul 2>&1
echo       [V] GitHub מעודכן
echo.

echo [2/3] מתקן את השרת (זה ייקח דקה)...
ssh root@31.97.129.5 "pm2 kill >/dev/null 2>&1; cd /home/emailapp/email-app && git pull -q && npm install -q && npm run build -q && cd backend && npm install -q && echo 'PORT=3001' > .env && pm2 start server.js --name backend -s && cd .. && pm2 serve dist 8080 --name frontend --spa -s && pm2 save -s && echo '127.0.0.1:3001' > /tmp/port && sed -i 's|proxy_pass http://[^;]*|proxy_pass http://127.0.0.1:3001|g' /etc/nginx/sites-available/email-app && nginx -s reload"
echo       [V] שרת מוכן
echo.

echo [3/3] בודק שהכל עובד...
ssh root@31.97.129.5 "pm2 list | grep -E 'backend|frontend' | grep online" >nul 2>&1
if %errorlevel% == 0 (
    echo       [V] הכל עובד!
) else (
    echo       [!] משהו לא בסדר - נסה שוב
)

echo.
echo ==================================
echo          הושלם בהצלחה!
echo ==================================
echo.
echo   כתובת: http://31.97.129.5
echo   משתמש: admin
echo   סיסמה: 123456
echo.
echo ==================================
echo.

pause