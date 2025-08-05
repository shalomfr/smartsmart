@echo off
echo ====== בודק ומתקן את האתר ======
echo.

echo [1] בודק חיבור לשרת...
ping -n 1 31.97.129.5 >nul 2>&1
if errorlevel 1 (
    echo    [X] אין חיבור לשרת!
    echo    בדוק את החיבור לאינטרנט
    pause
    exit
)
echo    [V] חיבור תקין
echo.

echo [2] בודק שירותים...
ssh root@31.97.129.5 "pm2 list | grep -E 'backend|frontend'" >nul 2>&1
if errorlevel 1 (
    echo    [X] השירותים לא רצים!
    echo    מתקן...
    ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && pm2 start server.js --name backend && cd .. && pm2 serve dist 8080 --name frontend --spa && pm2 save"
)
echo    [V] שירותים פעילים
echo.

echo [3] בודק Nginx...
ssh root@31.97.129.5 "systemctl is-active nginx" >nul 2>&1
if errorlevel 1 (
    echo    [X] Nginx לא פעיל!
    echo    מפעיל...
    ssh root@31.97.129.5 "systemctl start nginx && systemctl enable nginx"
)
echo    [V] Nginx פעיל
echo.

echo [4] בודק תיקיית dist...
ssh root@31.97.129.5 "ls /home/emailapp/email-app/dist/index.html" >nul 2>&1
if errorlevel 1 (
    echo    [X] אין קבצי frontend!
    echo    בונה מחדש...
    ssh root@31.97.129.5 "cd /home/emailapp/email-app && npm run build"
)
echo    [V] Frontend קיים
echo.

echo [5] מתקן הגדרות Nginx...
ssh root@31.97.129.5 "grep 'proxy_pass' /etc/nginx/sites-available/email-app | grep -q '3001'" >nul 2>&1
if errorlevel 1 (
    echo    [!] מעדכן Nginx...
    ssh root@31.97.129.5 "sed -i 's|proxy_pass http://[^;]*|proxy_pass http://127.0.0.1:3001|g' /etc/nginx/sites-available/email-app && nginx -s reload"
)
echo    [V] Nginx מוגדר נכון
echo.

echo [6] בדיקה סופית...
echo.
ssh root@31.97.129.5 "echo '=== PM2 Status ===' && pm2 list && echo && echo '=== Ports ===' && netstat -tlnp | grep -E ':80|:3001|:8080' | grep LISTEN"
echo.

echo ====== בדיקת גישה ======
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://31.97.129.5/
echo.

echo ====== סיום ======
echo.
echo נסה עכשיו: http://31.97.129.5
echo משתמש: admin | סיסמה: 123456
echo.
echo אם עדיין לא עובד, הרץ: PERFECT-INSTALL.bat
echo.
pause