@echo off
echo =============================================
echo   מעדכן שרת עם הגדרות מוצפנות
echo =============================================
echo.

echo 📡 מתחבר לשרת...
echo.

echo 1. מושך עדכונים מגיטהאב...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull"

echo.
echo 2. מתקין תלויות חדשות (אם יש)...
ssh root@31.97.129.5 "cd /home/emailapp/email-app/backend && npm install"

echo.
echo 3. מאתחל את השרת...
ssh root@31.97.129.5 "pm2 restart email-app-backend"

echo.
echo 4. בודק סטטוס...
ssh root@31.97.129.5 "pm2 status email-app-backend"

echo.
echo =============================================
echo ✅ השרת עודכן!
echo =============================================
echo.
echo כעת תוכל:
echo 1. להיכנס לאתר שלך
echo 2. ללכת להגדרות
echo 3. ללחוץ "שמור בשרת" כדי לשמור את ההגדרות
echo 4. במחשב אחר - ללחוץ "טען מהשרת"
echo.
pause