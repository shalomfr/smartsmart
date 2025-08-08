@echo off
chcp 65001 >nul
cls
color 0C
echo ================================================
echo      בדיקת בעיה ב-site3
echo ================================================
echo.

echo [1] בודק לוגים של site3...
echo ============================
ssh root@31.97.129.5 "pm2 logs site3-backend --lines 10"
echo.
ssh root@31.97.129.5 "pm2 logs site3-frontend --lines 10"

echo.
echo [2] בודק על איזה פורט באמת רצים...
echo ====================================
ssh root@31.97.129.5 "pm2 show site3-backend | grep -E 'script|port'"
ssh root@31.97.129.5 "pm2 show site3-frontend | grep -E 'script|port'"

echo.
echo [3] בודק את הקבצים ב-site3...
echo ===============================
ssh root@31.97.129.5 "cd /home/emailapp/site3 && ls -la"
ssh root@31.97.129.5 "cd /home/emailapp/site3/backend && grep 'PORT' server.js | head -5"

echo.
pause