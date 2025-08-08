@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *         בדיקה מדויקת של מערכת הכניסה           *
echo ****************************************************
echo.

echo [1] בודק אם יש משתמשי בדיקה מוגדרים...
echo ========================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -B5 -A20 'const users\\|mockUsers\\|testUsers\\|defaultUsers' server.js"

echo.
echo [2] בודק את נתיב ה-API לכניסה...
echo =================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -B5 -A30 '/api/auth/login' server.js | grep -v '^--'"

echo.
echo [3] בודק אם יש בדיקת סיסמה פשוטה...
echo =====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'password.*===\\|admin\\|test\\|demo\\|123' server.js"

echo.
echo [4] בודק לוגים של ניסיונות כניסה...
echo ====================================
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 20 | grep -E 'login\\|auth\\|password'"

echo.
pause