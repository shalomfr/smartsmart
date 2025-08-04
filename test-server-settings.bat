@echo off
echo =============================================
echo   בודק את מערכת ההגדרות החדשה
echo =============================================
echo.

echo 🔍 בודק אם ה-API החדש עובד...
echo.

curl -X GET http://31.97.129.5/api/settings/exists

echo.
echo.
echo אם אתה רואה: {"exists":false} - זה אומר שהמערכת עובדת!
echo אם אתה רואה: {"exists":true} - יש כבר הגדרות שמורות
echo.
echo 🌐 כדי לבדוק באתר:
echo    1. פתח: http://31.97.129.5
echo    2. כנס להגדרות
echo    3. חפש את הכפתורים החדשים:
echo       - "שמור בשרת" (ענן)
echo       - "טען מהשרת" (הורדה)
echo.
pause