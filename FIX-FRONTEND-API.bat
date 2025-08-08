@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *      תיקון חיבור Frontend ל-Backend             *
echo ****************************************************
echo.

echo [1] מעדכן את ה-API URL ב-AuthContext...
echo ========================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/contexts && cp AuthContext.jsx AuthContext.jsx.bak"

ssh root@31.97.129.5 "cd /home/emailapp/site2/src/contexts && sed -i \"s|window.location.hostname === 'localhost'|true|g\" AuthContext.jsx"
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/contexts && sed -i \"s|'http://localhost:3001/api'|'http://31.97.129.5:4000/api'|g\" AuthContext.jsx"

echo.
echo [2] בודק השינוי...
echo ==================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/contexts && grep -n 'API_URL' AuthContext.jsx"

echo.
echo [3] בונה מחדש...
echo =================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [4] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart site2-frontend"

echo.
echo ****************************************************
echo *          נסה עכשיו!                             *
echo ****************************************************
echo.
echo http://31.97.129.5:8082
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
pause