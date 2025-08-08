@echo off
chcp 65001 >nul
cls
color 0A
echo ===============================================
echo        🚀 העלאה מהירה לשרת 🚀
echo ===============================================
echo.

echo [1/4] 🏗️  בונה את הפרונטאנד...
call npm run build
if %errorlevel% neq 0 (
    echo ❌ שגיאה בבניית הפרונטאנד!
    pause
    exit /b
)
echo ✅ הפרונטאנד נבנה בהצלחה
echo.

echo [2/4] 📤 מעלה את השרת...
scp backend/server.js root@31.97.129.5:/home/emailapp/email-prod/backend/server.js
if %errorlevel% neq 0 (
    echo ❌ שגיאה בהעלאת השרת!
    pause
    exit /b
)
echo ✅ השרת הועלה בהצלחה
echo.

echo [3/4] 🌐 מעלה את הפרונטאנד...
scp -r dist/* root@31.97.129.5:/home/emailapp/email-prod/dist/
if %errorlevel% neq 0 (
    echo ❌ שגיאה בהעלאת הפרונטאנד!
    pause
    exit /b
)
echo ✅ הפרונטאנד הועלה בהצלחה
echo.

echo [4/4] 🔄 מפעיל מחדש את השרת...
ssh root@31.97.129.5 "pm2 restart email-backend"
if %errorlevel% neq 0 (
    echo ❌ שגיאה בהפעלה מחדש!
    pause
    exit /b
)
echo.

echo ================================================
echo           ✅ העלאה הושלמה בהצלחה! ✅
echo ================================================
echo.
echo 🌐 האתר זמין בכתובת: http://31.97.129.5:8081
echo 🔧 בדיקת סטטוס: CHECK-SERVER-STATUS.bat
echo 📋 מדריך מלא: DEPLOYMENT-GUIDE.md
echo.
echo לחץ כל מקש להמשך...
pause >nul