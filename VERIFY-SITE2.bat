@echo off
chcp 65001 >nul
cls
echo ================================================
echo      אימות site2 על פורט 9000
echo ================================================
echo.

echo בודק מה רץ על כל פורט...
echo ==========================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8080|8081|9000|4000)' | sort"

echo.
echo בודק קבצי הגדרות...
echo ====================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && grep -n 'PORT' .env 2>/dev/null || echo 'אין קובץ .env'"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && grep -n '9000' package.json 2>/dev/null || echo 'לא נמצא בpackage.json'"

echo.
echo ================================================
echo   סיכום:
echo ================================================
echo.
echo   site1 (ישן): http://31.97.129.5:8080
echo   site2 (חדש): http://31.97.129.5:9000
echo.
echo   Backend API: http://31.97.129.5:4000
echo.
echo   הטיוטות נמצאות ב-site2 על פורט 9000!
echo.
echo ================================================
echo.
pause