@echo off
echo ================================================
echo      שליטה ב-site2
echo ================================================
echo.
echo [1] הפעל את site2
echo [2] עצור את site2
echo [3] הפעל מחדש את site2
echo [4] הצג לוגים
echo [5] מחק את site2 (זהירות!)
echo [0] יציאה
echo.

set /p CHOICE="בחר אפשרות: "

if "%CHOICE%"=="1" goto start
if "%CHOICE%"=="2" goto stop
if "%CHOICE%"=="3" goto restart
if "%CHOICE%"=="4" goto logs
if "%CHOICE%"=="5" goto delete
if "%CHOICE%"=="0" exit

:start
echo.
echo מפעיל את site2...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && pm2 start server.js --name site2-backend && cd .. && pm2 serve dist 9000 --name site2-frontend --spa"
echo.
pause
exit

:stop
echo.
echo עוצר את site2...
ssh root@31.97.129.5 "pm2 stop site2-backend site2-frontend"
echo.
pause
exit

:restart
echo.
echo מפעיל מחדש את site2...
ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend"
echo.
pause
exit

:logs
echo.
echo מציג לוגים של site2...
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 20"
echo.
pause
exit

:delete
echo.
echo === אזהרה! זה ימחק את site2 לצמיתות! ===
set /p CONFIRM="האם אתה בטוח? (YES/NO): "
if not "%CONFIRM%"=="YES" exit

echo.
echo מוחק את site2...
ssh root@31.97.129.5 "pm2 delete site2-backend site2-frontend && rm -rf /home/emailapp/site2 && rm -f /etc/nginx/sites-enabled/site2 && rm -f /etc/nginx/sites-available/site2 && systemctl reload nginx"
echo.
echo site2 נמחק!
pause
exit