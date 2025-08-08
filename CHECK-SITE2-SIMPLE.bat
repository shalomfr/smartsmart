@echo off
echo ================================================
echo      בדיקת site2
echo ================================================
echo.

echo [1] בודק PM2...
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo [2] בודק פורטים...
ssh root@31.97.129.5 "netstat -tlnp | grep -E '4000|9000|8081'"

echo.
echo [3] בודק Nginx...
ssh root@31.97.129.5 "ls -la /etc/nginx/sites-enabled/ | grep site2"

echo.
echo [4] בודק תיקיית האתר...
ssh root@31.97.129.5 "ls -la /home/emailapp/ | grep site2"

echo.
echo [5] בודק גישה לאתר...
echo Testing http://31.97.129.5:8081
curl -s -o nul -w "Status: %%{http_code}\n" http://31.97.129.5:8081

echo.
echo ================================================
echo אם ראית:
echo - PM2: site2-backend ו-site2-frontend במצב online
echo - פורטים 4000, 9000, 8081 פתוחים
echo - Status: 200
echo.
echo אז האתר עובד!
echo גש ל: http://31.97.129.5:8081
echo ================================================
echo.
pause