@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *      תיקון בעיית Connection Timeout             *
echo ****************************************************
echo.

echo [1] בודק אם השרת חי...
echo ========================
ping -n 2 31.97.129.5

echo.
echo [2] בודק מה רץ על השרת...
echo ===========================
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo [3] בודק פורטים פתוחים...
echo ==========================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8082|4000)'"

echo.
echo [4] בודק חומת אש...
echo ====================
ssh root@31.97.129.5 "ufw status | grep -E '(8082|4000)'"

echo.
echo [5] מפעיל מחדש הכל...
echo ======================
ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend"

echo.
echo [6] אם site2-frontend לא רץ, מפעיל מחדש...
echo ===========================================
ssh root@31.97.129.5 "pm2 delete site2-frontend 2>/dev/null && cd /home/emailapp/site2 && pm2 serve dist 8082 --name site2-frontend --spa"

echo.
echo [7] בודק שוב...
echo ===============
ssh root@31.97.129.5 "pm2 list | grep site2"
ssh root@31.97.129.5 "netstat -tlnp | grep 8082"

echo.
pause