@echo off
chcp 65001 >nul
cls
color 0E
echo ================================================
echo      תיקון מהיר לבעיית כניסה
echo ================================================
echo.

echo שלב 1: מחזיר את הפורט ל-8081...
echo =================================
ssh root@31.97.129.5 "pm2 delete site2-frontend && cd /home/emailapp/site2 && pm2 serve dist 8081 --name site2-frontend --spa"

echo.
echo שלב 2: מוודא שה-backend רץ...
echo =============================
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo שלב 3: בודק פורטים...
echo =====================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)'"

echo.
echo ================================================
echo   נסה להיכנס עם:
echo ================================================
echo.
echo   כתובת: http://31.97.129.5:8081
echo.
echo   אפשרות 1:
echo   ----------
echo   אימייל: admin@example.com
echo   סיסמה: admin123
echo.
echo   אפשרות 2:
echo   ----------
echo   אימייל: user@example.com  
echo   סיסמה: password123
echo.
echo   אפשרות 3:
echo   ----------
echo   אימייל: test@example.com
echo   סיסמה: test123
echo.
echo ================================================
echo.
echo אם עדיין לא עובד - הפעל: CHECK-API-CONNECTION.bat
echo.
pause