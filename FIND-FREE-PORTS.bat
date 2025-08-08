@echo off
chcp 65001 >nul
cls
echo ================================================
echo      חיפוש פורטים פנויים
echo ================================================
echo.

echo [1] פורטים פתוחים בחומת אש...
echo ================================
ssh root@31.97.129.5 "ufw status | grep tcp | awk '{print $1}' | sort -n"

echo.
echo [2] פורטים תפוסים כרגע...
echo ==========================
ssh root@31.97.129.5 "netstat -tlnp | grep LISTEN | awk '{print $4}' | grep -o '[0-9]*$' | sort -n | uniq"

echo.
echo [3] פורטים מומלצים פנויים...
echo ==============================
echo מחפש פורטים פתוחים בחומת אש אבל לא תפוסים...
echo.

echo פורט 9000 - נבדק...
ssh root@31.97.129.5 "netstat -tlnp | grep :9000" 2>nul || echo ✓ פורט 9000 פנוי!

echo פורט 5173 - נבדק...
ssh root@31.97.129.5 "netstat -tlnp | grep :5173" 2>nul || echo ✓ פורט 5173 פנוי!

echo פורט 5000 - נבדק...
ssh root@31.97.129.5 "netstat -tlnp | grep :5000" 2>nul || echo ✓ פורט 5000 פנוי!

echo פורט 3000 - נבדק...
ssh root@31.97.129.5 "netstat -tlnp | grep :3000" 2>nul || echo ✓ פורט 3000 פנוי!

echo.
pause