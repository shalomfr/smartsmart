@echo off
echo ================================================
echo   סנכרון מלא של הקוד המקומי ל-site2
echo ================================================
echo.
echo אזהרה: זה ידרוס את כל הקבצים ב-site2!
echo.
set /p CONFIRM="האם להמשיך? (YES/NO): "
if not "%CONFIRM%"=="YES" exit

echo.
echo [1] מסנכרן את כל הקבצים...
echo ================================

REM מעלה את כל התיקייה (חוץ מ-node_modules)
echo יוצר רשימת קבצים לסנכרון...
echo backend > files-to-sync.txt
echo src >> files-to-sync.txt
echo public >> files-to-sync.txt
echo index.html >> files-to-sync.txt
echo package.json >> files-to-sync.txt
echo package-lock.json >> files-to-sync.txt
echo vite.config.js >> files-to-sync.txt
echo tailwind.config.js >> files-to-sync.txt
echo postcss.config.js >> files-to-sync.txt
echo components.json >> files-to-sync.txt
echo jsconfig.json >> files-to-sync.txt
echo eslint.config.js >> files-to-sync.txt

echo.
echo מעלה קבצים...
for /f "delims=" %%i in (files-to-sync.txt) do (
    echo מעלה %%i...
    scp -r "%%i" root@31.97.129.5:/home/emailapp/site2/ 2>nul
)

del files-to-sync.txt

echo.
echo [2] בונה מחדש את האתר...
echo ================================

ssh root@31.97.129.5 "bash -c 'cd /home/emailapp/site2 && echo \"Installing frontend packages...\" && npm install && echo \"Building frontend...\" && npm run build && cd backend && echo \"Installing backend packages...\" && npm install && echo \"Restarting services...\" && pm2 restart site2-backend && cd .. && pm2 restart site2-frontend && echo \"Done!\"'"

echo.
echo [3] בדיקת סטטוס סופית...
echo ================================

ssh root@31.97.129.5 "pm2 status | grep -E 'site2|Name' && echo && curl -s -o /dev/null -w 'Site status: %%{http_code}\n' http://localhost:8081"

echo.
echo ================================================
echo   ✅ הסנכרון הושלם!
echo ================================================
echo.
echo site2 עודכן עם כל השינויים המקומיים!
echo.
echo כתובת: http://31.97.129.5:8081
echo.
echo תכונות חדשות:
echo - תוויות (labels) למיילים
echo - כל השיפורים שעשית מקומית
echo.
pause