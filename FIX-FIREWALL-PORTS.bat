@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *         פתיחת פורטים בחומת האש                 *
echo ****************************************************
echo.

echo [1] פותח פורטים בחומת האש...
echo ==============================
ssh root@31.97.129.5 "ufw allow 8080/tcp"
ssh root@31.97.129.5 "ufw allow 8081/tcp"
ssh root@31.97.129.5 "ufw allow 8082/tcp"
ssh root@31.97.129.5 "ufw allow 9000/tcp"
ssh root@31.97.129.5 "ufw allow 4000/tcp"

echo.
echo [2] מפעיל מחדש את חומת האש...
echo ===============================
ssh root@31.97.129.5 "ufw reload"

echo.
echo [3] בודק סטטוס חומת אש...
echo ==========================
ssh root@31.97.129.5 "ufw status numbered"

echo.
echo [4] מוודא שהשירותים רצים...
echo ============================
ssh root@31.97.129.5 "pm2 restart all"

echo.
echo [5] בודק פורטים פתוחים...
echo ==========================
ssh root@31.97.129.5 "netstat -tlnp | grep LISTEN"

echo.
echo ****************************************************
echo *               סיימנו!                            *
echo ****************************************************
echo.
pause