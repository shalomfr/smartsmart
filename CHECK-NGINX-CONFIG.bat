@echo off
chcp 65001 >nul
cls
echo ================================================
echo      בדיקת הגדרות NGINX
echo ================================================
echo.

echo מה רץ על פורט 8081?
echo ====================
ssh root@31.97.129.5 "grep -r '8081' /etc/nginx/ 2>/dev/null | head -10"

echo.
echo בודק אתרים פעילים...
echo =====================
ssh root@31.97.129.5 "ls -la /etc/nginx/sites-enabled/"

echo.
echo בודק אם זה proxy ל-site2...
echo ============================
ssh root@31.97.129.5 "grep -r 'proxy_pass.*9000' /etc/nginx/ 2>/dev/null"

echo.
echo ================================================
echo אם nginx מכוון ל-9000, אז:
echo הכתובת הנכונה היא http://31.97.129.5:8081
echo והוא יעביר אוטומטית ל-site2!
echo ================================================
echo.
pause