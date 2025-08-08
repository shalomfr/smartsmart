@echo off
chcp 65001 >nul
cls
echo ================================================
echo      מחזיר את הפורט ל-8081
echo ================================================
echo.

echo [1] עוצר את site2-frontend...
ssh root@31.97.129.5 "pm2 stop site2-frontend"

echo.
echo [2] מעדכן את הפורט ל-8081...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 delete site2-frontend"

echo.
echo [3] מפעיל מחדש על פורט 8081...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 start ecosystem.config.js --only site2-frontend --update-env"

echo.
echo [4] אם לא עובד, מפעיל ידנית...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8081 --name site2-frontend --spa"

echo.
echo [5] בודק שרץ על הפורט הנכון...
ssh root@31.97.129.5 "pm2 list | grep site2"
ssh root@31.97.129.5 "netstat -tlnp | grep 8081"

echo.
echo ================================================
echo   הפורט הוחזר ל-8081!
echo   כתובת: http://31.97.129.5:8081
echo ================================================
echo.
pause