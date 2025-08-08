@echo off
chcp 65001 >nul
cls
color 0D
echo ===============================================
echo        🌐 העלאת פרונטאנד בלבד 🌐
echo ===============================================
echo.

echo [1/2] 🏗️  בונה את הפרונטאנד...
call npm run build
if %errorlevel% neq 0 (
    echo ❌ שגיאה בבניית הפרונטאנד!
    pause
    exit /b
)
echo ✅ הפרונטאנד נבנה בהצלחה
echo.

echo [2/2] 📤 מעלה את הפרונטאנד...
scp -r dist/* root@31.97.129.5:/home/emailapp/email-prod/dist/
if %errorlevel% neq 0 (
    echo ❌ שגיאה בהעלאת הפרונטאנד!
    pause
    exit /b
)
echo ✅ הפרונטאנד הועלה בהצלחה
echo.

echo ================================================
echo          ✅ הפרונטאנד עודכן בהצלחה! ✅
echo ================================================
echo.
echo 🌐 האתר זמין בכתובת: http://31.97.129.5:8081
echo 💡 טיפ: רענן את הדפדפן עם Ctrl+Shift+R
echo.
echo לחץ כל מקש להמשך...
pause >nul