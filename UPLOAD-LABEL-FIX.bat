@echo off
echo ===============================================
echo     מעלה תיקון לבעיית התוויות
echo ===============================================
echo.

echo [1] מעלה קובץ מתוקן...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [2] מפעיל מחדש את השרת...
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [3] מציג לוגים...
timeout /t 3 >nul
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 100 | grep -A 5 'Labels Debug'"

echo.
echo ===============================================
echo התיקונים שביצענו:
echo 1. הסרת \ מתחילת התוויות (Important במקום \Important)
echo 2. תרגום תוויות עבריות מקודדות
echo 3. שיפור הלוגים
echo ===============================================
echo.
echo עכשיו פתח מחדש את האתר וטען מייל חדש!
echo.
pause