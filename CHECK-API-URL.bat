@echo off
chcp 65001 >nul
cls
echo ================================================
echo      בדיקת כתובת API
echo ================================================
echo.

echo בודק את קובץ settingsAPI.js המקומי...
echo ======================================
type src\api\settingsAPI.js | findstr /n "apiUrl"

echo.
echo בודק את הקובץ בשרת...
echo ======================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/api && grep -n 'apiUrl' settingsAPI.js 2>/dev/null || echo 'הקובץ לא נמצא'"

echo.
echo בודק בקבצים הבנויים...
echo ======================
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && grep -h 'http://.*:4000' *.js | head -5 2>/dev/null || echo 'לא נמצא'"

echo.
echo ================================================
echo   אם הכתובת היא localhost:4000
echo   במקום 31.97.129.5:4000 - זו הבעיה!
echo ================================================
echo.
pause