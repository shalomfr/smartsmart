@echo off
cls
color 0E
echo.
echo    ╔════════════════════════════════════════╗
echo    ║                                        ║
echo    ║     📧 EMAIL APP - התקנה מהירה 📧     ║
echo    ║                                        ║
echo    ╚════════════════════════════════════════╝
echo.
echo.
echo    1. בדיקה מקדימה
echo    2. התקנה מלאה (מומלץ!)
echo    3. בדיקת מצב שרת
echo    4. יציאה
echo.
echo.
set /p choice="    בחר אפשרות (1-4): "

if "%choice%"=="1" call PRE-DEPLOY-CHECK.bat & goto end
if "%choice%"=="2" call START-FRESH.bat & goto end
if "%choice%"=="3" call CHECK-SERVER-STATUS.bat & goto end
if "%choice%"=="4" exit

:end
echo.
echo    לחץ Enter לחזור לתפריט...
pause >nul
GO.bat