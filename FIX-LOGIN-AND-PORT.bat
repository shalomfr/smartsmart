@echo off
chcp 65001 >nul
cls
echo ================================================
echo      תיקון כניסה ופורט
echo ================================================
echo.

echo [1] בודק הגדרות סיסמה...
echo ==========================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && grep -n 'password' .env 2>/dev/null || echo 'אין קובץ .env'"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && grep -n 'PASSWORD' backend/server.js | head -5"

echo.
echo [2] מתקן את הפורט...
echo ====================
ssh root@31.97.129.5 "pm2 delete site2-frontend"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8081 --name site2-frontend --spa"

echo.
echo [3] מפעיל מחדש את הbackend...
echo =============================
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [4] בודק סטטוס...
echo =================
ssh root@31.97.129.5 "pm2 list"

echo.
echo ================================================
echo   פרטי כניסה:
echo ================================================
echo.
echo   כתובת: http://31.97.129.5:8081
echo.
echo   שם משתמש: admin
echo   סיסמה: 123456
echo.
echo   או נסה:
echo   שם משתמש: test@example.com
echo   סיסמה: password123
echo.
echo ================================================
echo.
pause