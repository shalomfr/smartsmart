@echo off
echo ===== מתקן את פורט 80 =====
echo.

echo [1] בודק מה תופס את פורט 80...
ssh root@31.97.129.5 "lsof -i :80"

echo.
echo [2] בודק סטטוס Nginx...
ssh root@31.97.129.5 "systemctl status nginx | grep Active"

echo.
echo [3] בודק הגדרות Nginx...
ssh root@31.97.129.5 "cat /etc/nginx/sites-available/email-app"

echo.
echo [4] מתקן Nginx מחדש...
ssh root@31.97.129.5 "systemctl stop nginx && rm -f /etc/nginx/sites-enabled/* && ln -s /etc/nginx/sites-available/email-app /etc/nginx/sites-enabled/ && systemctl start nginx"

echo.
echo [5] אם Nginx לא עולה, מתקן ברוטאלי...
ssh root@31.97.129.5 "pkill -9 nginx; rm -f /var/run/nginx.pid; systemctl start nginx"

echo.
echo [6] בדיקה סופית...
ssh root@31.97.129.5 "netstat -tlnp | grep :80"
ssh root@31.97.129.5 "systemctl status nginx | grep Active"

echo.
echo [7] בודק גישה...
timeout /t 3 /nobreak >nul
curl -I http://31.97.129.5

echo.
echo נסה עכשיו: http://31.97.129.5
echo או ישירות: http://31.97.129.5:8080
echo.
pause