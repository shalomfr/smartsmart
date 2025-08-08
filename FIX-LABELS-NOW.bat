@echo off
echo ================================================
echo   תיקון התוויות - הסרת קודים מוזרים
echo ================================================
echo.
echo השיפורים:
echo - תרגום "Important" (עם i קטנה) ל"חשוב"
echo - הסרת תוויות עם קודים מוזרים כמו "-BdEF2QXq&"
echo - הסתרת תוויות ארוכות מדי
echo - תמיכה ב-case insensitive
echo.
pause

echo.
echo [1] מעלה את התיקון לשני האתרים...
echo ================================

echo מעלה לאתר הראשי...
scp backend/server.js root@31.97.129.5:/home/emailapp/email-app/backend/server.js

echo.
echo מעלה ל-site2...
scp backend/server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [2] מפעיל מחדש את השירותים...
echo ================================

ssh root@31.97.129.5 "pm2 restart backend site2-backend"

echo.
echo [3] בודק סטטוס...
echo ================================

ssh root@31.97.129.5 "pm2 list | grep -E 'backend|Name'"

echo.
echo ================================================
echo   ✅ התוויות תוקנו!
echo ================================================
echo.
echo עכשיו תראה:
echo - "חשוב" במקום "Important"
echo - ללא קודים מוזרים
echo - רק תוויות רלוונטיות
echo.
echo בדוק ב:
echo - אתר ראשי: http://31.97.129.5
echo - site2: http://31.97.129.5:8081
echo.
pause