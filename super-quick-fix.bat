@echo off
REM ==========================================
REM Super Quick Fix - גרסה מהירה וקצרה
REM ==========================================

echo תיקון מהיר מתחיל...

REM Push to GitHub
git add . && git commit -m "Quick fix %time%" && git push --force

REM Fix everything on server in one command
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm install && npm run build && cd backend && npm install && echo 'PORT=3003' > .env && pm2 delete all && pm2 start server.js --name email-app-backend && cd .. && pm2 serve dist 8080 --name email-app-frontend --spa && pm2 save && sed -i 's/proxy_pass.*$/proxy_pass http:\/\/localhost:3003\/api\/;/' /etc/nginx/sites-available/email-app && nginx -s reload && pm2 status"

echo.
echo הושלם! בדוק ב: http://31.97.129.5
echo.
pause