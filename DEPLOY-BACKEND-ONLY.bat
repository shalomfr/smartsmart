@echo off
chcp 65001 >nul
cls
color 0E
echo ===============================================
echo        🔧 העלאת שרת בלבד 🔧
echo ===============================================
echo.

echo [1/2] 📤 מעלה את קובץ השרת...
scp backend/server.js root@31.97.129.5:/home/emailapp/email-prod/backend/server.js
if %errorlevel% neq 0 (
    echo ❌ שגיאה בהעלאת השרת!
    pause
    exit /b
)
echo ✅ השרת הועלה בהצלחה
echo.

echo [2/2] 🔄 מפעיל מחדש...
ssh root@31.97.129.5 "pm2 restart email-backend"
if %errorlevel% neq 0 (
    echo ❌ שגיאה בהפעלה מחדש!
    pause
    exit /b
)
echo.

echo ================================================
echo           ✅ השרת עודכן בהצלחה! ✅
echo ================================================
echo.
echo 🌐 האתר זמין בכתובת: http://31.97.129.5:8081
echo 📊 לבדיקת סטטוס: CHECK-SERVER-STATUS.bat
echo.
echo לחץ כל מקש להמשך...
pause >nul