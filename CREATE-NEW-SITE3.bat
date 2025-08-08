@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *      יצירת אתר חדש - site3                      *
echo *      Frontend: פורט 5173                        *
echo *      Backend: פורט 5000                         *
echo ****************************************************
echo.

echo [1] יוצר תיקיה חדשה בשרת...
echo =============================
ssh root@31.97.129.5 "mkdir -p /home/emailapp/site3"

echo.
echo [2] מעתיק את כל הקבצים...
echo ==========================
echo מעלה Frontend...
scp -r src root@31.97.129.5:/home/emailapp/site3/
scp -r public root@31.97.129.5:/home/emailapp/site3/
scp package.json package-lock.json vite.config.js index.html root@31.97.129.5:/home/emailapp/site3/
scp tailwind.config.js postcss.config.js components.json root@31.97.129.5:/home/emailapp/site3/
scp jsconfig.json eslint.config.js root@31.97.129.5:/home/emailapp/site3/ 2>nul

echo.
echo מעלה Backend...
scp -r backend root@31.97.129.5:/home/emailapp/site3/

echo.
echo [3] מעדכן את הפורטים...
echo ========================
echo מעדכן Backend לפורט 5000...
ssh root@31.97.129.5 "cd /home/emailapp/site3/backend && sed -i 's/const PORT = 4000/const PORT = 5000/' server.js"
ssh root@31.97.129.5 "cd /home/emailapp/site3/backend && sed -i 's/port 4000/port 5000/' server.js"

echo.
echo מעדכן Frontend לפורט 5000...
ssh root@31.97.129.5 "cd /home/emailapp/site3/src/contexts && sed -i 's/localhost:3001/localhost:5000/g' AuthContext.jsx"
ssh root@31.97.129.5 "cd /home/emailapp/site3/src/contexts && sed -i 's/localhost:4000/localhost:5000/g' AuthContext.jsx"
ssh root@31.97.129.5 "cd /home/emailapp/site3/src/contexts && sed -i \"s|const API_URL = .*|const API_URL = 'http://31.97.129.5:5000/api';|\" AuthContext.jsx"

echo.
echo [4] מתקין תלויות...
echo ===================
ssh root@31.97.129.5 "cd /home/emailapp/site3 && npm install"
ssh root@31.97.129.5 "cd /home/emailapp/site3/backend && npm install"

echo.
echo [5] בונה את הפרויקט...
echo ======================
ssh root@31.97.129.5 "cd /home/emailapp/site3 && npm run build"

echo.
echo [6] מפעיל עם PM2...
echo ===================
ssh root@31.97.129.5 "cd /home/emailapp/site3/backend && pm2 start server.js --name site3-backend"
ssh root@31.97.129.5 "cd /home/emailapp/site3 && pm2 serve dist 5173 --name site3-frontend --spa"

echo.
echo [7] פותח פורטים בחומת אש...
echo ============================
ssh root@31.97.129.5 "ufw allow 5173/tcp && ufw allow 5000/tcp && ufw reload"

echo.
echo [8] בודק סטטוס...
echo =================
ssh root@31.97.129.5 "pm2 list | grep site3"
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(5173|5000)'"

echo.
echo ****************************************************
echo *               סיימנו! 🎉                        *
echo ****************************************************
echo.
echo האתר החדש זמין ב:
echo http://31.97.129.5:5173
echo.
echo כניסה עם:
echo שם משתמש: admin
echo סיסמה: 123456
echo.
echo ****************************************************
echo.
pause