@echo off
chcp 65001 >nul
cls
echo ================================================
echo        פתרון פשוט שעובד
echo ================================================
echo.

echo מנקה הכל ומתחיל מחדש...
ssh root@31.97.129.5 "pm2 stop all && pm2 delete all"

echo.
echo מפעיל רק את site2...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 start ecosystem.config.js"

echo.
echo אם לא עבד, מפעיל ידנית...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 start backend/server.js --name site2-backend"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 serve dist 8081 --name site2-frontend --spa"

echo.
echo סטטוס סופי:
ssh root@31.97.129.5 "pm2 list"

echo.
echo ================================================
echo.
echo גש ל: http://31.97.129.5:8081
echo.
echo והתחבר עם:
echo אימייל: admin@example.com
echo סיסמה: admin123
echo.
echo ================================================
echo.
pause