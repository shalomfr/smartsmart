@echo off
echo ========================================
echo   בודק בעיית שליחת מיילים
echo ========================================
echo.

echo 1. בודק אם ה-Backend פועל...
ssh root@31.97.129.5 "pm2 status"

echo.
echo 2. בודק לוגים של Backend...
ssh root@31.97.129.5 "pm2 logs email-app-backend --lines 20 | grep -E 'email|send|smtp|error'"

echo.
echo 3. בודק את ה-API endpoint...
curl -X GET http://31.97.129.5/api/emails

echo.
echo ========================================
echo שלח לי את התוצאות!
echo ========================================
pause