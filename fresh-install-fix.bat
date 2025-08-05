@echo off
chcp 65001 > nul
echo =============================================
echo   🔄 התקנה נקייה מאפס
echo =============================================
echo.
echo ⚠️  זהירות: זה ימחק הכל ויתקין מחדש!
echo.
pause

echo.
echo 🗑️ מוחק את הכל...
ssh root@31.97.129.5 "pm2 delete all && pm2 save --force"
ssh root@31.97.129.5 "cd /home/emailapp && rm -rf email-app"

echo.
echo 📥 מוריד מחדש מגיטהאב...
ssh root@31.97.129.5 "cd /home/emailapp && git clone https://github.com/shalomfr/smartsmart.git email-app"

echo.
echo 📦 מתקין תלויות...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && npm install"

echo.
echo 🏗️ בונה את האפליקציה...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && npm run build"

echo.
echo 📦 מתקין תלויות Backend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && npm install"

echo.
echo 📝 מגדיר Backend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && echo 'PORT=3003' > .env"

echo.
echo 🚀 מפעיל Backend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && pm2 start server.js --name email-app-backend"

echo.
echo 🌐 מפעיל Frontend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && pm2 serve dist 8080 --name email-app-frontend --spa"

echo.
echo 🔧 מעדכן Nginx...
ssh root@31.97.129.5 "sed -i 's/localhost:[0-9]*/localhost:3003/g' /etc/nginx/sites-available/email-app"
ssh root@31.97.129.5 "nginx -s reload"

echo.
echo 💾 שומר...
ssh root@31.97.129.5 "pm2 save --force"

echo.
echo ✅ בדיקה סופית...
ssh root@31.97.129.5 "pm2 status"

echo.
echo =============================================
echo   ✅ ההתקנה הנקייה הושלמה!
echo =============================================
echo.
echo האתר: http://31.97.129.5
echo.
pause