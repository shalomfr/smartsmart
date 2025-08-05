@echo off
echo תיקון בלחיצה אחת - מתחיל...

REM Everything in one command
ssh root@31.97.129.5 "pm2 delete all 2>/dev/null; cd /home/emailapp/email-app && git pull && npm install && npm run build && cd backend && npm install && echo 'PORT=3001' > .env && pm2 start server.js --name email-app-backend && cd .. && pm2 serve dist 8080 --name email-app-frontend --spa && pm2 save && sed -i 's|proxy_pass.*|proxy_pass http://127.0.0.1:3001;|g' /etc/nginx/sites-available/email-app && nginx -s reload && echo && echo '=== STATUS ===' && pm2 status && echo && echo 'Fixed! Go to http://31.97.129.5'"

echo.
echo ===== הושלם! =====
echo http://31.97.129.5
echo משתמש: admin | סיסמה: 123456
echo.
pause