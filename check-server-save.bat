@echo off
echo ========================================
echo   בודק את מערכת השמירה בשרת
echo ========================================
echo.

echo 1. בודק אם ה-API עובד...
curl -X GET http://31.97.129.5/api/settings/exists

echo.
echo.
echo 2. בודק את ה-backend...
ssh root@31.97.129.5 "pm2 status"

echo.
echo 3. בודק לוגים אחרונים...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && tail -20 /root/.pm2/logs/email-app-backend-error.log"

echo.
echo ========================================
echo אם יש שגיאות - שלח לי אותן
echo ========================================
pause