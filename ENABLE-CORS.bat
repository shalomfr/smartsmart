@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *           הפעלת CORS ב-Backend                  *
echo ****************************************************
echo.

echo [1] בודק הגדרות CORS נוכחיות...
echo ==================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'cors' server.js"

echo.
echo [2] מעדכן CORS לאפשר גישה מכל מקום...
echo ========================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cp server.js server.js.backup"

ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && sed -i 's/app.use(cors());/app.use(cors({ origin: true, credentials: true }));/' server.js"

echo.
echo [3] מפעיל מחדש את ה-Backend...
echo ================================
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [4] ממתין 3 שניות...
timeout /t 3 /nobreak >nul

echo.
echo [5] בודק שה-API עובד...
echo =======================
ssh root@31.97.129.5 "curl -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"

echo.
echo ****************************************************
echo *           CORS מופעל!                           *
echo ****************************************************
echo.
pause