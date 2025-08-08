@echo off
chcp 65001 >nul
echo ================================================
echo   התקנת פענוח אוטומטי לכל התוויות בעברית
echo ================================================
echo.

echo [1] מתקין חבילת UTF7 בשרת...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && npm install utf7"

echo.
echo [2] מעלה קוד מעודכן...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js
scp backend\package.json root@31.97.129.5:/home/emailapp/site2/backend/package.json

echo.
echo [3] מפעיל מחדש את השרת...
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [4] ממתין לאתחול...
timeout /t 5 >nul

echo.
echo ================================================
echo    הפענוח האוטומטי מותקן!
echo ================================================
echo.
echo עכשיו כל תווית בעברית תתורגם אוטומטית:
echo   &BdEF2QXq-     →  משפחה
echo   &BdAF3AXj-     →  עבודה
echo   &כל-תווית-אחרת  →  תתורגם אוטומטית!
echo.
echo ================================================
echo.
echo בדוק את זה: 
echo 1. פתח את האתר: http://31.97.129.5:8081
echo 2. טען מיילים עם תוויות בעברית
echo 3. כל התוויות אמורות להופיע בעברית!
echo.
pause