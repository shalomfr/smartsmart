@echo off
echo ========================================
echo   תיקון מהיר לבעיית השמירה
echo ========================================
echo.

echo מתחבר לשרת ומאתחל מחדש...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && cd backend && npm install && pm2 restart email-app-backend && pm2 save"

echo.
echo בודק סטטוס...
ssh root@31.97.129.5 "pm2 status"

echo.
echo ========================================
echo ✅ נסה שוב לשמור בשרת!
echo ========================================
pause