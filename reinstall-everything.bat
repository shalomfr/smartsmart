@echo off
echo =============================================
echo   🔄 התקנה מחדש של הכל
echo =============================================
echo.
echo זהירות! זה ימחק את הכל ויתקין מחדש.
echo.
pause

echo מתחיל התקנה מחדש...
echo.

ssh root@31.97.129.5 "pm2 delete all && pm2 save --force && cd /home/emailapp && rm -rf email-app && git clone https://github.com/shalomfr/smartsmart.git email-app && cd email-app && npm install && npm run build && cd backend && npm install && echo 'PORT=3002' > .env && pm2 start server.js --name email-app-backend && cd .. && pm2 serve dist 8080 --name email-app-frontend --spa && pm2 save && sed -i 's/localhost:3001/localhost:3002/g' /etc/nginx/sites-available/email-app && nginx -s reload"

echo.
echo בודק סטטוס סופי...
ssh root@31.97.129.5 "pm2 status"

echo.
echo =============================================
echo ✅ ההתקנה הושלמה!
echo =============================================
echo.
echo האתר: http://31.97.129.5
echo.
pause