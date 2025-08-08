@echo off
echo ================================================
echo      ניהול כל האתרים ב-VPS
echo ================================================
echo.

echo [1] הצג את כל האתרים
echo [2] הפעל מחדש אתר ספציפי
echo [3] עצור אתר ספציפי
echo [4] הפעל מחדש את כל האתרים
echo [5] הצג לוגים של אתר
echo [6] מחק אתר
echo [0] יציאה
echo.

set /p CHOICE="בחר אפשרות: "

if "%CHOICE%"=="1" goto show_all
if "%CHOICE%"=="2" goto restart_site
if "%CHOICE%"=="3" goto stop_site
if "%CHOICE%"=="4" goto restart_all
if "%CHOICE%"=="5" goto show_logs
if "%CHOICE%"=="6" goto delete_site
if "%CHOICE%"=="0" exit

:show_all
echo.
echo === כל האתרים הפעילים ===
ssh root@31.97.129.5 "pm2 list && echo && echo 'Nginx Sites:' && ls -la /etc/nginx/sites-enabled/"
echo.
pause
goto end

:restart_site
echo.
set /p SITE="הכנס שם אתר (למשל: site2): "
ssh root@31.97.129.5 "pm2 restart %SITE%-backend %SITE%-frontend"
echo.
pause
goto end

:stop_site
echo.
set /p SITE="הכנס שם אתר (למשל: site2): "
ssh root@31.97.129.5 "pm2 stop %SITE%-backend %SITE%-frontend"
echo.
pause
goto end

:restart_all
echo.
echo מפעיל מחדש את כל האתרים...
ssh root@31.97.129.5 "pm2 restart all && systemctl restart nginx"
echo.
pause
goto end

:show_logs
echo.
set /p SITE="הכנס שם אתר (למשל: site2): "
ssh root@31.97.129.5 "pm2 logs %SITE%-backend --lines 20"
echo.
pause
goto end

:delete_site
echo.
echo === אזהרה! פעולה זו תמחק את האתר לצמיתות! ===
set /p SITE="הכנס שם אתר למחיקה: "
set /p CONFIRM="האם אתה בטוח? (yes/no): "
if not "%CONFIRM%"=="yes" goto end

ssh root@31.97.129.5 "pm2 delete %SITE%-backend %SITE%-frontend && rm -rf /home/emailapp/%SITE% && rm -f /etc/nginx/sites-enabled/%SITE% && rm -f /etc/nginx/sites-available/%SITE% && systemctl reload nginx"
echo.
echo האתר %SITE% נמחק!
pause
goto end

:end