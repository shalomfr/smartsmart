@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *      פתרון חכם - משתמשים בפורט אחר              *
echo ****************************************************
echo.

echo nginx תופס את 8081, אז נשתמש בפורט 8082!
echo.

echo [1] מוחק frontend ישן...
echo ========================
ssh root@31.97.129.5 "pm2 delete site2-frontend 2>/dev/null || true"

echo.
echo [2] מפעיל על פורט 8082...
echo ==========================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8082 --name site2-frontend --spa"

echo.
echo [3] בודק סטטוס...
echo =================
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo [4] בודק פורטים...
echo ==================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8082|4000)'"

echo.
echo ****************************************************
echo *               🎉 הצלחנו! 🎉                      *
echo ****************************************************
echo.
echo הכתובת החדשה היא:
echo.
echo   http://31.97.129.5:8082
echo.
echo התחבר עם:
echo   אימייל: admin@example.com
echo   סיסמה: admin123
echo.
echo ****************************************************
echo.
pause

start http://31.97.129.5:8082