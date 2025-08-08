@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *      תיקון בעיית אימות - משתמשי בדיקה          *
echo ****************************************************
echo.

echo [1] בודק את קוד האימות ב-Backend...
echo ====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'mockUsers\\|imap\\|IMAP' server.js | head -20"

echo.
echo [2] בודק איזה endpoint נקרא...
echo ==============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -A20 '/api/auth/login' server.js | head -30"

echo.
echo [3] מפעיל מחדש עם DEBUG...
echo ==========================
ssh root@31.97.129.5 "pm2 restart site2-backend --update-env"

echo.
echo [4] בודק לוגים אחרונים...
echo =========================
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 15"

echo.
pause