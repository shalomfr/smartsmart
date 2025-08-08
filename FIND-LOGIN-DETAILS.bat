@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *          חיפוש פרטי כניסה במערכת               *
echo ****************************************************
echo.

echo [1] מחפש הגדרות משתמשים ב-Backend...
echo =====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -i -n 'admin\\|user.*:.*{\\|password.*:' server.js | head -20"

echo.
echo [2] מחפש בקבצי הגדרות...
echo =========================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && find . -name '*.json' -o -name '*.js' | xargs grep -l 'username\\|password' 2>/dev/null | head -10"

echo.
echo [3] בודק אם יש קובץ README או SETUP...
echo =======================================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && ls -la README* SETUP* INSTALL* LOGIN* 2>/dev/null"
ssh root@31.97.129.5 "cd /home/emailapp/site2 && cat README* 2>/dev/null | grep -i 'login\\|password\\|username' | head -10"

echo.
echo [4] בודק את הקוד של validateAuth...
echo ====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -B10 -A10 'validateAuth\\|checkAuth\\|authenticate' server.js | head -30"

echo.
pause