@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *           בדיקת חירום - מה לא עובד?           *
echo ****************************************************
echo.

echo [1] בודק אם Backend רץ על פורט 4000...
echo =========================================
ssh root@31.97.129.5 "netstat -tlnp | grep 4000"
if errorlevel 1 (
    echo ❌ Backend לא רץ על פורט 4000!
) else (
    echo ✅ Backend רץ
)

echo.
echo [2] בודק מה כתוב בקבצים הבנויים...
echo =====================================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/dist/assets && grep -o 'http://[^\"]*:4000' *.js | head -5 || echo 'לא נמצא URL לפורט 4000!'"

echo.
echo [3] בודק אם יש URLs חלקיים...
echo ===============================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/dist/assets && grep -o ':4000/[^\"]*' *.js | head -5"

echo.
echo [4] בודק לוגים של Backend...
echo =============================
ssh root@31.97.129.5 "pm2 logs email-backend --lines 20 | grep -E 'listening|error|Error'"

echo.
pause