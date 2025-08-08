@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *            תיקון מלא - Frontend + Login          *
echo ****************************************************
echo.

echo שלב 1: מתקן את ה-Frontend...
echo =============================
ssh root@31.97.129.5 "pm2 delete site2-frontend 2>/dev/null || true"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8081 --name site2-frontend --spa"

echo.
echo שלב 2: מוודא שה-Backend רץ נכון...
echo ==================================
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo שלב 3: ממתין 5 שניות לאתחול...
timeout /t 5 /nobreak >nul

echo.
echo שלב 4: בודק סטטוס...
echo ====================
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo שלב 5: בודק פורטים...
echo =====================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)'"

echo.
echo ****************************************************
echo *                 סיימנו!                          *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8081
echo.
echo נסה את כל האפשרויות האלה:
echo ===========================
echo.
echo 1) אימייל: admin@example.com
echo    סיסמה: admin123
echo.
echo 2) אימייל: user@example.com
echo    סיסמה: password123
echo.
echo 3) אימייל: test@test.com
echo    סיסמה: test123
echo.
echo ****************************************************
echo.
echo אם עדיין לא עובד:
echo 1. נקה מטמון דפדפן (Ctrl+Shift+Delete)
echo 2. השתמש בחלון גלישה פרטית (Ctrl+Shift+N)
echo.
pause