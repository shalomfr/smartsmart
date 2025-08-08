@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *      תיקון קבצי API חסרים                      *
echo ****************************************************
echo.

echo [1] בודק מה יש בתיקיית API בשרת...
echo =====================================
ssh root@31.97.129.5 "ls -la /home/emailapp/email-prod/src/api/"

echo.
echo [2] מעלה את קבצי ה-API...
echo ==========================
scp -r src/api root@31.97.129.5:/home/emailapp/email-prod/src/

echo.
echo [3] מתקן את ה-URLs בקבצי API...
echo ================================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/src/api && for f in *.js; do sed -i 's|http://localhost:[0-9]*|http://31.97.129.5:4000|g' \$f; done"

echo.
echo [4] בודק את realEmailAPI.js...
echo ===============================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/src/api && grep -n 'export' realEmailAPI.js | head -5"

echo.
echo [5] מוסיף export חסר אם צריך...
echo =================================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/src/api && echo 'export const realEmailAPI = Account;' >> realEmailAPI.js"

echo.
echo [6] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && npm run build"

echo.
echo [7] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart email-frontend"

echo.
echo ****************************************************
echo *              תיקון הושלם!                       *
echo ****************************************************
echo.
pause