@echo off
echo =============================================
echo   הגדרת Git Credentials
echo =============================================
echo.

echo הסקריפט הזה יעזור לך להגדיר את הגישה לגיטהאב
echo.

echo 1. מגדיר credential helper...
git config --global credential.helper manager-core
echo.

echo 2. בודק משתמש...
set /p name="הכנס את השם שלך לגיט (או Enter לדלג): "
if not "%name%"=="" (
    git config --global user.name "%name%"
    echo הוגדר: %name%
)

set /p email="הכנס את המייל שלך לגיט (או Enter לדלג): "
if not "%email%"=="" (
    git config --global user.email "%email%"
    echo הוגדר: %email%
)

echo.
echo 3. מגדיר הרשאות לאחסון סיסמאות...
git config --global credential.helper wincred
echo.

echo ✅ מוכן!
echo.
echo כעת כשתנסה להעלות לגיט, תתבקש להתחבר פעם אחת
echo והסיסמה תישמר לפעמים הבאות.
echo.
echo להעלאה, הרץ את: upload-settings-update.bat
echo.
pause