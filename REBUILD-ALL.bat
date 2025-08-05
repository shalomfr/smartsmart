@echo off
echo ===== בונה הכל מחדש =====
echo.

echo [1] מתקן התקנת npm...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && rm -rf node_modules package-lock.json && npm cache clean --force && npm install"

echo.
echo [2] בונה את האתר...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && npm run build && ls -la dist/"

echo.
echo [3] מפעיל מחדש שירותים...
ssh root@31.97.129.5 "pm2 restart all"

echo.
echo [4] מתקן Nginx (פשוט)...
ssh root@31.97.129.5 "systemctl restart nginx"

echo.
echo [5] בדיקה סופית...
timeout /t 5 /nobreak >nul
curl -I http://31.97.129.5

echo.
echo נסה עכשיו: http://31.97.129.5
echo.
pause