@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *         מוצא פורטים פנויים אוטומטית            *
echo ****************************************************
echo.

echo [1] סורק פורטים פנויים בטווח 6000-6010...
echo ============================================
ssh root@31.97.129.5 "for port in {6000..6010}; do netstat -tlnp 2>/dev/null | grep -q :$port || echo Port $port is FREE; done"

echo.
echo [2] פותח פורטים בחומת אש...
echo ==============================
ssh root@31.97.129.5 "ufw allow 6000/tcp && ufw allow 6001/tcp && ufw reload"

echo.
echo [3] משתמש בפורטים הבטוחים 6000 ו-6001...
echo ==========================================
echo.
echo Frontend: 6000
echo Backend: 6001
echo.
pause