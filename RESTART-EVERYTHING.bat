@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *         הפעלה מחדש של הכל                      *
echo ****************************************************
echo.

echo [1] עוצר הכל...
echo ===============
ssh root@31.97.129.5 "pm2 stop all && pm2 delete all"

echo.
echo [2] מנקה תהליכים תקועים...
echo ==========================
ssh root@31.97.129.5 "killall node 2>/dev/null || true"

echo.
echo [3] מפעיל רק את site2...
echo =========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && pm2 start server.js --name site2-backend"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8082 --name site2-frontend --spa"

echo.
echo [4] בודק שהכל רץ...
echo ===================
timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "pm2 list"

echo.
echo [5] בודק פורטים...
echo ==================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8082|4000)'"

echo.
echo [6] בודק גישה...
echo =================
ssh root@31.97.129.5 "curl -I http://localhost:8082 2>&1 | head -5"

echo.
echo ****************************************************
echo *          נסה עכשיו!                             *
echo ****************************************************
echo.
echo http://31.97.129.5:8082
echo.
pause