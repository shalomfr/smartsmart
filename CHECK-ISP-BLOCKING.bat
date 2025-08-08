@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *    בדיקה: האם הספק שלך חוסם פורטים?           *
echo ****************************************************
echo.

echo [1] בודק חיבור בסיסי לשרת...
echo ==============================
ping -n 2 31.97.129.5
if %errorlevel% neq 0 (
    echo ✗ אין חיבור לשרת כלל!
) else (
    echo ✓ יש חיבור לשרת
)

echo.
echo [2] בודק פורט 22 (SSH)...
echo ==========================
powershell -Command "Test-NetConnection -ComputerName 31.97.129.5 -Port 22"

echo.
echo [3] בודק פורט 8082...
echo =====================
powershell -Command "Test-NetConnection -ComputerName 31.97.129.5 -Port 8082"

echo.
echo [4] בודק פורט 8080...
echo =====================
powershell -Command "Test-NetConnection -ComputerName 31.97.129.5 -Port 8080"

echo.
echo ****************************************************
echo *                  מסקנות                         *
echo ****************************************************
echo.
echo אם פורט 22 עובד אבל 8082 לא:
echo - הבעיה בשרת (השירות לא רץ)
echo.
echo אם שום פורט לא עובד חוץ מ-22:
echo - כנראה הספק שלך חוסם פורטים
echo - נסה VPN או רשת אחרת (סלולר)
echo.
echo אם הכל נכשל:
echo - אין חיבור לשרת בכלל
echo.
pause