@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *          מוסיף פורט 8082 לחומת האש             *
echo ****************************************************
echo.

echo [1] מוסיף פורט 8082...
echo =======================
ssh root@31.97.129.5 "ufw allow 8082/tcp"

echo.
echo [2] טוען מחדש את החומת אש...
echo =============================
ssh root@31.97.129.5 "ufw reload"

echo.
echo [3] בודק סטטוס...
echo =================
ssh root@31.97.129.5 "ufw status | grep 8082"

echo.
echo [4] בודק שהאתר עובד...
echo ======================
ssh root@31.97.129.5 "curl -I http://localhost:8082 2>/dev/null | head -3"

echo.
echo ****************************************************
echo *                 סיימנו! 🎉                       *
echo ****************************************************
echo.
echo עכשיו תוכל להיכנס ל:
echo http://31.97.129.5:8082
echo.
echo עם הפרטים:
echo אימייל: admin@example.com
echo סיסמה: admin123
echo.
echo ****************************************************
echo.
echo לחץ Enter לפתוח בדפדפן...
pause >nul

start http://31.97.129.5:8082