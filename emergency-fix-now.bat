@echo off
echo ===== תיקון חירום - מתקן הכל =====
echo.

echo [1] בודק חיבור...
ping -n 1 31.97.129.5 >nul 2>&1
if errorlevel 1 (
    echo [X] אין חיבור לשרת!
    pause
    exit
)
echo [V] חיבור תקין
echo.

echo [2] מתקן הכל בשרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm install && npm run build && cd backend && npm install && echo 'PORT=3001' > .env"

echo [3] מפעיל שירותים...
ssh root@31.97.129.5 "pm2 delete all 2>/dev/null; cd /home/emailapp/email-app/backend && pm2 start server.js --name backend && cd .. && pm2 serve dist 8080 --name frontend --spa && pm2 save --force"

echo [4] מתקן Nginx...
ssh root@31.97.129.5 "systemctl start nginx; systemctl enable nginx"

echo [5] פותח פורטים...
ssh root@31.97.129.5 "ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp && ufw allow 3001/tcp && ufw allow 8080/tcp && ufw --force enable"

echo [6] בדיקה סופית...
echo.
ssh root@31.97.129.5 "echo '=== PM2 ===' && pm2 list && echo && echo '=== Nginx ===' && systemctl status nginx | grep Active && echo && echo '=== Ports ===' && netstat -tlnp | grep LISTEN | grep -E ':80|:3001|:8080'"

echo.
echo ===== בדיקת גישה =====
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://31.97.129.5/
echo.

echo נסה עכשיו: http://31.97.129.5
echo.
pause