@echo off
echo ================================================
echo    תיקון אולטימטיבי - מתקן הכל מאפס
echo ================================================
echo.

echo [1/10] מתחבר לשרת ומנקה הכל...
ssh root@31.97.129.5 "pm2 kill && killall -9 node 2>/dev/null || true && lsof -ti:3001 | xargs kill -9 2>/dev/null || true && lsof -ti:3003 | xargs kill -9 2>/dev/null || true"

echo.
echo [2/10] מושך קוד עדכני...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git fetch --all && git reset --hard origin/main && git pull"

echo.
echo [3/10] מנקה ומתקין חבילות Frontend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && rm -rf node_modules dist package-lock.json && npm cache clean --force && npm install --force"

echo.
echo [4/10] מתקין Vite ובונה Frontend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && npm install vite @vitejs/plugin-react --save-dev && npm run build"

echo.
echo [5/10] בודק שנוצרה תיקיית dist...
ssh root@31.97.129.5 "ls -la /home/emailapp/email-app/dist/"

echo.
echo [6/10] מתקין Backend...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && rm -rf node_modules package-lock.json && npm install"

echo.
echo [7/10] יוצר קובץ .env נכון...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && echo 'PORT=3001' > .env && echo 'NODE_ENV=production' >> .env"

echo.
echo [8/10] מפעיל שירותים עם PM2...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && pm2 start server.js --name backend && cd /home/emailapp/email-app && pm2 serve dist 8080 --name frontend --spa && pm2 save --force"

echo.
echo [9/10] מתקן Nginx...
ssh root@31.97.129.5 "systemctl restart nginx"

echo.
echo [10/10] בדיקה סופית...
timeout /t 5 /nobreak >nul
ssh root@31.97.129.5 "echo && echo '=== PM2 Status ===' && pm2 list && echo && echo '=== Ports ===' && netstat -tlnp | grep -E ':80|:3001|:8080' | grep LISTEN"

echo.
echo בודק גישה לאתר...
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo ================================================
echo              הושלם!
echo ================================================
echo.
echo אתר: http://31.97.129.5
echo משתמש: admin
echo סיסמה: 123456
echo.
echo אם עדיין לא עובד:
echo 1. בדוק בדפדפן אחר
echo 2. נקה cache (Ctrl+F5)
echo 3. חכה דקה ונסה שוב
echo.
pause