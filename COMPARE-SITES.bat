@echo off
echo ================================================
echo   השוואה בין האתר הראשי ל-site2
echo ================================================
echo.

echo [1] גרסאות קוד:
echo ================================
ssh root@31.97.129.5 "echo 'Main site:' && head -5 /home/emailapp/email-app/backend/server.js | grep -E 'version|Version' || echo 'No version info' && echo && echo 'Site2:' && head -5 /home/emailapp/site2/backend/server.js | grep -E 'version|Version' || echo 'No version info'"

echo.
echo [2] בדיקת תמיכה בתוויות:
echo ================================
ssh root@31.97.129.5 "echo 'Main site labels support:' && grep -c 'labels:' /home/emailapp/email-app/backend/server.js && echo 'Site2 labels support:' && grep -c 'labels:' /home/emailapp/site2/backend/server.js"

echo.
echo [3] סטטוס PM2:
echo ================================
ssh root@31.97.129.5 "pm2 list"

echo.
echo [4] תאריכי עדכון אחרון:
echo ================================
ssh root@31.97.129.5 "echo 'Main site:' && ls -la /home/emailapp/email-app/backend/server.js | awk '{print $6, $7, $8}' && echo 'Site2:' && ls -la /home/emailapp/site2/backend/server.js | awk '{print $6, $7, $8}'"

echo.
echo ================================================
echo   כתובות האתרים:
echo ================================================
echo.
echo אתר ראשי: http://31.97.129.5
echo   - ללא תוויות (אם לא עודכן)
echo.
echo site2: http://31.97.129.5:8081
echo   - עם תוויות (אחרי העדכון)
echo.
pause