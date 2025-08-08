@echo off
chcp 65001 >nul
cls
color 0B
echo ===============================================
echo        📊 בדיקת סטטוס השרת 📊
echo ===============================================
echo.

echo [1/4] 🔍 סטטוס PM2:
echo ----------------------------------------
ssh root@31.97.129.5 "pm2 status"
echo.

echo [2/4] 📋 לוגים אחרונים:
echo ----------------------------------------
ssh root@31.97.129.5 "pm2 logs email-backend --lines 10"
echo.

echo [3/4] 🌐 בדיקת חיבור HTTP:
echo ----------------------------------------
curl -I http://31.97.129.5:8081 2>nul
if %errorlevel% neq 0 (
    echo ⚠️ לא ניתן להתחבר לשרת
) else (
    echo ✅ השרת מגיב
)
echo.

echo [4/4] 💾 שימוש במערכת:
echo ----------------------------------------
ssh root@31.97.129.5 "df -h /home && free -h"
echo.

echo ================================================
echo בדיקה הושלמה
echo ================================================
echo.
echo 🔧 להפעלה מחדש: ssh root@31.97.129.5 "pm2 restart email-backend"
echo 📋 לוגים מלאים: ssh root@31.97.129.5 "pm2 logs email-backend"
echo 🌐 כתובת האתר: http://31.97.129.5:8081
echo.
echo לחץ כל מקש להמשך...
pause >nul