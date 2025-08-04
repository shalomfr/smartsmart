@echo off
echo =============================================
echo   🔧 מוודא שה-Backend פועל
echo =============================================
echo.

echo בודק סטטוס...
ssh root@31.97.129.5 "pm2 status"

echo.
echo מתקן את פורט 3001...
ssh root@31.97.129.5 "lsof -ti:3001 | xargs kill -9 2>/dev/null || true"

echo.
echo מאתחל תהליכים...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && pm2 delete email-app-backend 2>/dev/null || true && pm2 start server.js --name email-app-backend"

echo.
echo בודק סטטוס סופי...
ssh root@31.97.129.5 "pm2 status"

echo.
echo ✅ Backend אמור לפעול עכשיו!
echo.
pause