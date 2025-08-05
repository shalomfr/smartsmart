@echo off
echo ========== תיקון מלא ==========

REM Push to GitHub
git add . && git commit -m "Fix %time%" && git push --force

REM Fix everything on server
ssh root@31.97.129.5 "pm2 delete all; cd /home/emailapp/email-app && git pull && npm install && npm run build && cd backend && npm install && echo 'PORT=3001' > .env && pm2 start server.js --name email-app-backend && cd .. && pm2 serve dist 8080 --name email-app-frontend --spa && pm2 save"

REM Fix Nginx
ssh root@31.97.129.5 "sed -i 's|proxy_pass.*|proxy_pass http://127.0.0.1:3001;|g' /etc/nginx/sites-available/email-app && nginx -s reload"

REM Show status
ssh root@31.97.129.5 "pm2 status"

echo.
echo ========== הושלם! ==========
echo גש ל: http://31.97.129.5
echo שם משתמש: admin
echo סיסמה: 123456
echo.
pause