@echo off
chcp 65001 >nul
:menu
cls
echo ================================================
echo           בקרת site2
echo ================================================
echo.
echo 1. Build and Restart
echo 2. Build עם לוגים
echo 3. צפה בלוגים בזמן אמת
echo 4. בדוק סטטוס PM2
echo 5. Restart בלבד
echo 6. Build בלבד
echo 7. פתח את האתר בדפדפן
echo 8. יציאה
echo.
set /p choice=בחר אפשרות (1-8): 

if "%choice%"=="1" (
    echo.
    ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build && pm2 restart site2-backend site2-frontend"
    echo.
    pause
    goto menu
)
if "%choice%"=="2" (
    call BUILD-WITH-LOGS.bat
    goto menu
)
if "%choice%"=="3" (
    call WATCH-LOGS.bat
    goto menu
)
if "%choice%"=="4" (
    echo.
    ssh root@31.97.129.5 "pm2 status"
    echo.
    pause
    goto menu
)
if "%choice%"=="5" (
    echo.
    ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend"
    echo.
    pause
    goto menu
)
if "%choice%"=="6" (
    echo.
    ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"
    echo.
    pause
    goto menu
)
if "%choice%"=="7" (
    start http://31.97.129.5:8081
    goto menu
)
if "%choice%"=="8" exit

goto menu