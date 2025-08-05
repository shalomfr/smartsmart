@echo off
echo ===== בדיקה מלאה של המערכת =====
echo.

echo [1] בודק חיבור לשרת...
ping -n 1 31.97.129.5 >nul 2>&1 && echo    [V] חיבור תקין || echo    [X] אין חיבור

echo.
echo [2] בודק שירותי PM2...
ssh root@31.97.129.5 "pm2 list"

echo.
echo [3] בודק Nginx...
ssh root@31.97.129.5 "systemctl status nginx | grep Active"

echo.
echo [4] בודק פורטים פתוחים...
ssh root@31.97.129.5 "netstat -tlnp | grep -E ':80|:8080|:3001'"

echo.
echo [5] בודק קבצי dist...
ssh root@31.97.129.5 "ls -la /home/emailapp/email-app/dist/ | head -5"

echo.
echo [6] בודק לוגים של שגיאות...
ssh root@31.97.129.5 "tail -5 /var/log/nginx/error.log"

echo.
echo ===== בדיקות גישה =====
echo.
echo נסה את הכתובות האלה:
echo 1. http://31.97.129.5 (דרך Nginx)
echo 2. http://31.97.129.5:8080 (Frontend ישיר)
echo 3. http://31.97.129.5:3001/api/app/login (Backend ישיר)
echo.
pause