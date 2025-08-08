@echo off
chcp 65001 >nul
cls
color 0B
echo ****************************************************
echo *           תיקון חכם אוטומטי                     *
echo ****************************************************
echo.

echo שלב 1: בודק מה תופס את 8081...
echo =================================
ssh root@31.97.129.5 "netstat -tlnp | grep 8081"

echo.
echo שלב 2: בודק אם nginx מגדיר proxy...
echo ====================================
ssh root@31.97.129.5 "grep -l '8081' /etc/nginx/sites-enabled/* 2>/dev/null | head -1"

echo.
echo אם nginx תופס את 8081, משתמשים בפורט אחר...
echo.

echo שלב 3: מוחק ומפעיל מחדש...
echo ===========================
ssh root@31.97.129.5 "pm2 delete site2-frontend 2>/dev/null || true"

echo.
echo מנסה פורט 8082...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8082 --name site2-frontend --spa"

echo.
echo שלב 4: מוודא ש-backend רץ...
echo ============================
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo שלב 5: סטטוס סופי...
echo ====================
ssh root@31.97.129.5 "pm2 list | grep site2"
echo.
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8082|4000)'"

echo.
echo ****************************************************
echo *              📍 כתובות גישה                     *
echo ****************************************************
echo.
echo אפשרות 1: http://31.97.129.5:8082
echo אפשרות 2: http://31.97.129.5:8081 (אם nginx מכוון נכון)
echo.
echo כניסה למערכת:
echo   אימייל: admin@example.com
echo   סיסמה: admin123
echo.
echo ****************************************************
echo.
echo לחץ Enter לפתוח בדפדפן...
pause >nul

start http://31.97.129.5:8082