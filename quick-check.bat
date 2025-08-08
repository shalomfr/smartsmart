@echo off
cls
echo ════════════════════════════════════════════════════
echo              בדיקה מהירה
echo ════════════════════════════════════════════════════
echo.
echo בודק מה רץ...
ssh root@31.97.129.5 "pm2 list | grep -E 'site2|8082|4000' && echo. && netstat -tlnp | grep -E '(8082|4000)'"
echo.
echo ════════════════════════════════════════════════════
echo.
echo מנסה כניסה ישירה ל-API...
ssh root@31.97.129.5 "curl -s -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"
echo.
echo ════════════════════════════════════════════════════
echo.
echo אם ראית "success":true - ה-Backend עובד!
echo הבעיה ב-Frontend.
echo.
echo הפעל: REBUILD-AND-FIX.bat
echo.
pause