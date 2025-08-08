@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *      ניקוי והתקנה נקייה - site3                *
echo ****************************************************
echo.
echo אזהרה: זה ימחק את site3 אם קיים!
echo.
echo לחץ Ctrl+C לביטול או Enter להמשך...
pause >nul

echo.
echo [1] עוצר תהליכים ישנים של site3...
echo ====================================
ssh root@31.97.129.5 "pm2 delete site3-backend site3-frontend 2>/dev/null || true"

echo.
echo [2] מוחק תיקיה ישנה...
echo =======================
ssh root@31.97.129.5 "rm -rf /home/emailapp/site3"

echo.
echo [3] מכין URLs נכונים...
echo =======================
echo מעדכן AuthContext...
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) | ForEach-Object { $_ -replace 'const API_URL = .*', 'const API_URL = ''http://31.97.129.5:5000/api'';' } | Set-Content src\contexts\AuthContext.jsx"

echo.
echo [4] מעלה קבצים...
echo ==================
call CREATE-NEW-SITE3.bat

echo.
echo ****************************************************
echo *           הושלם בהצלחה!                         *
echo ****************************************************
echo.
pause