@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *         תיקון התנגשות עם NGINX                  *
echo ****************************************************
echo.

echo [1] עוצר את nginx...
echo ====================
ssh root@31.97.129.5 "systemctl stop nginx || service nginx stop"

echo.
echo [2] מוחק את site2-frontend הקרוס...
echo ====================================
ssh root@31.97.129.5 "pm2 delete site2-frontend"

echo.
echo [3] מפעיל מחדש על פורט 8081...
echo ===============================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8081 --name site2-frontend --spa"

echo.
echo [4] בודק סטטוס...
echo =================
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo [5] בודק פורטים...
echo ==================
ssh root@31.97.129.5 "netstat -tlnp | grep 8081"

echo.
echo ****************************************************
echo *                  סיימנו!                         *
echo ****************************************************
echo.
echo עכשיו תוכל להיכנס ל:
echo http://31.97.129.5:8081
echo.
echo עם הפרטים:
echo אימייל: admin@example.com
echo סיסמה: admin123
echo.
pause