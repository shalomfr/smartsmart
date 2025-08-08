@echo off
cls
echo ════════════════════════════════════════════════════
echo              בדיקת מצב מהירה
echo ════════════════════════════════════════════════════
echo.
ssh root@31.97.129.5 "echo '[תהליכים רצים]' && pm2 list | grep email && echo && echo '[פורטים פתוחים]' && netstat -tlnp | grep -E '(8081|4000)' && echo && echo '[בדיקת API]' && curl -s http://localhost:4000/api/app/login -X POST -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"
echo.
echo ════════════════════════════════════════════════════
echo.
echo אם אתה רואה:
echo ✓ email-backend + email-frontend רצים
echo ✓ פורט 8081 ופורט 4000 פתוחים
echo ✓ "success":true בתשובת API
echo.
echo אז הכל עובד! היכנס ל:
echo http://31.97.129.5:8081
echo.
pause