@echo off
chcp 65001 >nul
echo ================================================
echo      בדיקת פענוח אוטומטי של תוויות
echo ================================================
echo.

echo מעלה קוד מעודכן...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo מפעיל מחדש...
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo ממתין...
timeout /t 3 >nul

echo.
echo ================================================
echo צופה בלוגים (Ctrl+C לעצירה)...
echo ================================================
echo.
echo חפש שורות כמו:
echo   Auto-decoded Hebrew: "&BdEF2QXq-" -> "משפחה"
echo   Auto-decoded Hebrew (method 2): ...
echo.
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 100 | grep -E '(Auto-decoded|Processing:|Failed to decode|Could not decode)'"