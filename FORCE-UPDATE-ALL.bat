@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *        עדכון כוחני - מחליף הכל                 *
echo ****************************************************
echo.
echo זה יחליף את כל הקבצים בשרת!
echo.
pause

echo.
echo [1] עוצר את site2...
echo ====================
ssh root@31.97.129.5 "pm2 stop site2-backend site2-frontend"

echo.
echo [2] מוחק תיקיות ישנות...
echo =========================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && rm -rf src dist node_modules backend/node_modules"

echo.
echo [3] מעלה הכל מחדש...
echo =====================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && mkdir -p src backend"
scp -r src/* root@31.97.129.5:/home/emailapp/site2/src/
scp -r public package*.json vite.config.js index.html *.config.js components.json jsconfig.json root@31.97.129.5:/home/emailapp/site2/ 2>nul
scp -r backend/* root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo [4] מתקין מחדש...
echo =================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm install"
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && npm install"

echo.
echo [5] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [6] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 start site2-backend site2-frontend"

echo.
echo [7] בדיקה סופית...
echo ===================
timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "pm2 list | grep site2"
echo.
echo בודק API...
ssh root@31.97.129.5 "curl -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"

echo.
echo ****************************************************
echo *              נסה עכשיו!                         *
echo ****************************************************
echo.
echo http://31.97.129.5:8082
echo.
echo admin / 123456
echo.
pause