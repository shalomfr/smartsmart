@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *      העברה לפורט 80 - פורט סטנדרטי              *
echo ****************************************************
echo.

echo [1] עוצר שירותים על פורט 80...
echo ================================
ssh root@31.97.129.5 "systemctl stop apache2 2>/dev/null || true"
ssh root@31.97.129.5 "systemctl stop nginx 2>/dev/null || true"

echo.
echo [2] מעביר את site2 לפורט 80...
echo ===============================
ssh root@31.97.129.5 "pm2 delete site2-frontend"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 80 --name site2-frontend --spa"

echo.
echo [3] בודק סטטוס...
echo =================
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo [4] בודק פורט 80...
echo ===================
ssh root@31.97.129.5 "netstat -tlnp | grep :80"

echo.
echo ****************************************************
echo *                🎉 סיימנו! 🎉                     *
echo ****************************************************
echo.
echo עכשיו אתה יכול להיכנס בלי לציין פורט!
echo.
echo   http://31.97.129.5
echo.
echo   (בלי :8082 או משהו אחר)
echo.
echo כניסה:
echo   אימייל: admin@example.com
echo   סיסמה: admin123
echo.
echo ****************************************************
echo.
pause

start http://31.97.129.5