@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *         תיקון מהיר לבעיית CORS                  *
echo ****************************************************
echo.

echo [1] מעדכן CORS ב-Backend...
echo ===========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && sed -i 's/app.use(cors());/app.use(cors({ origin: true, credentials: true }));/' server.js"

echo.
echo [2] מפעיל מחדש את ה-Backend...
echo ==============================
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [3] בודק שה-Backend רץ על פורט 4000...
echo ======================================
ssh root@31.97.129.5 "netstat -tlnp | grep 4000"

echo.
echo [4] בודק לוגים...
echo =================
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 5"

echo.
echo ****************************************************
echo *     נסה עכשיו להתחבר עם:                       *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8082
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
echo ****************************************************
echo.
pause