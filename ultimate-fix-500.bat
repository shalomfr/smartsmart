@echo off
chcp 65001 > nul
echo =============================================
echo   🚀 תיקון סופי לשגיאת 500
echo =============================================
echo.

echo 🔍 שלב 1: בודק מה המצב...
ssh root@31.97.129.5 "pm2 status"

echo.
echo 🏗️ שלב 2: בונה הכל מחדש...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm install && npm run build"

echo.
echo 🔧 שלב 3: מתקן את ה-Backend...
ssh root@31.97.129.5 "pm2 delete all"
ssh root@31.97.129.5 "killall -9 node 2>/dev/null || true"
ssh root@31.97.129.5 "lsof -ti:3001 | xargs kill -9 2>/dev/null || true"
ssh root@31.97.129.5 "lsof -ti:3002 | xargs kill -9 2>/dev/null || true"

echo.
echo 📝 שלב 4: מגדיר פורט חדש...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && echo 'PORT=3003' > .env"

echo.
echo 🚀 שלב 5: מפעיל את הכל...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && npm install && pm2 start server.js --name email-app-backend"
ssh root@31.97.129.5 "cd /home/emailapp/email-app && pm2 serve dist 8080 --name email-app-frontend --spa"

echo.
echo 🌐 שלב 6: מעדכן Nginx...
ssh root@31.97.129.5 "sed -i 's/localhost:[0-9]*/localhost:3003/g' /etc/nginx/sites-available/email-app"
ssh root@31.97.129.5 "nginx -t && nginx -s reload"

echo.
echo 💾 שלב 7: שומר הגדרות...
ssh root@31.97.129.5 "pm2 save --force"
ssh root@31.97.129.5 "pm2 startup"

echo.
echo ✅ שלב 8: בדיקה סופית...
ssh root@31.97.129.5 "pm2 status"

echo.
echo =============================================
echo   ✅ התיקון הושלם!
echo =============================================
echo.
echo 🌐 האתר: http://31.97.129.5
echo.
echo אם עדיין יש בעיה, נסה:
echo 1. לנקות את הcache של הדפדפן
echo 2. לפתוח בחלון גלישה בסתר
echo 3. להמתין 30 שניות ולרענן
echo.
pause