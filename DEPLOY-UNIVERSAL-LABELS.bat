@echo off
chcp 65001 >nul
echo ================================================
echo   התקנת פענוח אוניברסלי לתוויות עבריות
echo ================================================
echo.
echo פתרון מלא שמפענח אוטומטית כל תווית בעברית!
echo.

echo [1] התקנת חבילת UTF7...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && npm install utf7 --save" 2>nul || (
    echo שגיאה בהתקנה! בודק אם כבר מותקן...
    ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && npm list utf7"
)

echo.
echo [2] מעלה קבצים מעודכנים...
scp backend\package.json root@31.97.129.5:/home/emailapp/site2/backend/package.json
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [3] מפעיל מחדש את השרת...
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [4] ממתין לאתחול...
timeout /t 5 >nul

echo.
echo ================================================
echo       ✓ ההתקנה הושלמה בהצלחה!
echo ================================================
echo.
echo מה הותקן:
echo   ✓ פענוח אוטומטי של תוויות מקודדות
echo   ✓ תרגום תוויות באנגלית
echo   ✓ תמיכה בתוויות שכבר בעברית
echo.
echo דוגמאות:
echo   &BdEF2QXq-  →  משפחה
echo   &BdAF3AXj-  →  עבודה
echo   Important   →  חשוב
echo   Sent        →  נשלח
echo.
echo ================================================
echo.
echo פתח עכשיו: http://31.97.129.5:8081
echo וראה את כל התוויות בעברית!
echo.
pause