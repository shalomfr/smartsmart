@echo off
echo מעדכן את השרת עם הגדרות מוצפנות...
echo.

ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && cd backend && npm install && pm2 restart email-app-backend && echo 'Server updated successfully!'"

echo.
echo ✅ השרת עודכן!
pause