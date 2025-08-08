@echo off
chcp 65001 >nul
cls
color 0C
echo ================================================
echo      תיקון שגיאת Frontend
echo ================================================
echo.

echo [1] בודק למה הפרונטאנד קרס...
echo ===============================
ssh root@31.97.129.5 "pm2 logs site2-frontend --lines 20"

echo.
echo [2] מוחק ומפעיל מחדש...
echo ========================
ssh root@31.97.129.5 "pm2 delete site2-frontend"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8081 --name site2-frontend --spa"

echo.
echo [3] בודק שרץ...
echo ===============
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
echo [4] בודק פורטים...
echo ==================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)'"

echo.
pause