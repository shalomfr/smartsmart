@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *      העברה לפורט 80 - תמיד עובד!               *
echo ****************************************************
echo.

echo [1] עוצר שירותים על פורט 80...
echo ================================
ssh root@31.97.129.5 "systemctl stop apache2 nginx 2>/dev/null || true"
ssh root@31.97.129.5 "fuser -k 80/tcp 2>/dev/null || true"

echo.
echo [2] מעביר את site2 לפורט 80...
echo ===============================
ssh root@31.97.129.5 "pm2 delete site2-frontend 2>/dev/null || true"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 80 --name site2-frontend --spa"

echo.
echo [3] בודק שעובד...
echo =================
timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "pm2 list | grep site2"
ssh root@31.97.129.5 "netstat -tlnp | grep :80"

echo.
echo ****************************************************
echo *               זהו! עכשיו נסה:                   *
echo ****************************************************
echo.
echo http://31.97.129.5
echo.
echo (בלי פורט! פורט 80 הוא ברירת המחדל)
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
echo ****************************************************
echo.
pause

start http://31.97.129.5