@echo off
chcp 65001 >nul
cls
echo ================================================
echo         אבחון סופי - מה הבעיה?
echo ================================================
echo.

echo צעד 1: בודק איזה אתרים רצים...
echo ================================
ssh root@31.97.129.5 "pm2 list"

echo.
echo צעד 2: בודק את site2 (האתר הנכון)...
echo ====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'תיקיית site2:' && grep 'בהמתנה לתשובה' Layout.jsx && echo 'נמצא!' || echo 'לא נמצא!'"

echo.
echo צעד 3: בודק את site1 (האתר הישן)...
echo ===================================
ssh root@31.97.129.5 "cd /home/emailapp/site1/src/pages && echo 'תיקיית site1:' && grep 'בהמתנה לתשובה' Layout.jsx && echo 'נמצא!' || echo 'לא נמצא!'"

echo.
echo ================================================
echo              📋 סיכום מצב:
echo ================================================
echo.
echo   site1 (פורט 8080) = אתר ישן ללא טיוטות
echo   site2 (פורט 8081) = אתר חדש עם טיוטות
echo.
echo   🎯 חובה להיכנס ל: http://31.97.129.5:8081
echo.
echo ================================================
echo.
echo לחץ Enter לפתוח את האתר הנכון...
pause >nul
start http://31.97.129.5:8081