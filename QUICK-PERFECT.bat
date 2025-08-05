@echo off
REM === Quick Perfect Install - גרסה מהירה ===

echo ══════════════════════════════════
echo    התקנה מהירה ומושלמת
echo ══════════════════════════════════
echo.

echo [1] מעדכן GitHub...
git add . && git commit -m "Update" && git push --force

echo.
echo [2] מתקין בשרת (זה ייקח 2 דקות)...
ssh root@31.97.129.5 "pm2 kill && systemctl stop nginx && cd /home/emailapp/email-app && git pull && rm -rf node_modules dist && npm install && npm run build && cd backend && rm -rf node_modules && npm install && echo 'PORT=3001' > .env && pm2 start server.js --name backend && cd .. && pm2 serve dist 8080 --name frontend --spa && pm2 save --force && systemctl start nginx && systemctl reload nginx"

echo.
echo [3] בודק...
timeout /t 3 /nobreak >nul
curl -s -o nul -w "Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo ══════════════════════════════════
echo ✓ הושלם!
echo ══════════════════════════════════
echo.
echo כתובת: http://31.97.129.5
echo משתמש: admin
echo סיסמה: 123456
echo.
pause