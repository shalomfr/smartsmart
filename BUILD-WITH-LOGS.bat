@echo off
chcp 65001 >nul
echo ================================================
echo       בנייה והפעלה מחדש עם לוגים
echo ================================================
echo.

echo [1] בונה...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build 2>&1"

echo.
echo [2] מפעיל מחדש...
ssh root@31.97.129.5 "pm2 restart site2-backend site2-frontend"

echo.
echo [3] מחכה 3 שניות...
timeout /t 3 >nul

echo.
echo [4] בודק לוגים...
echo.
echo === Backend Logs ===
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 10 --nostream"

echo.
echo === Frontend Logs ===
ssh root@31.97.129.5 "pm2 logs site2-frontend --lines 10 --nostream"

echo.
echo ================================================
echo בדוק את האתר: http://31.97.129.5:8081
echo ================================================
pause