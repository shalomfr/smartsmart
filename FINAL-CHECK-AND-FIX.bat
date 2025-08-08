@echo off
chcp 65001 >nul
echo ================================================
echo      בדיקה סופית ותיקון מטמון
echo ================================================
echo.

echo [1] מפעיל מחדש עם רענון מלא...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && pm2 stop site2-backend site2-frontend && pm2 flush && pm2 start site2-backend && pm2 start site2-frontend"

echo.
echo [2] בודק שהשרתים רצים...
ssh root@31.97.129.5 "pm2 status | grep site2"

echo.
echo ================================================
echo     הכל מוכן! עכשיו חובה לעשות:
echo ================================================
echo.
echo בדפדפן שלך:
echo.
echo אפשרות 1 (מומלץ):
echo   - פתח חלון גלישה בסתר/פרטית חדש
echo   - Ctrl+Shift+N (Chrome) או Ctrl+Shift+P (Firefox)
echo.
echo אפשרות 2:
echo   - לחץ Ctrl+Shift+Delete
echo   - בחר "נקה מטמון" או "Cached images and files"
echo   - לחץ "נקה נתונים"
echo.
echo אפשרות 3:
echo   - באתר עצמו לחץ Ctrl+F5 (לא רק F5!)
echo.
echo ================================================
echo.
echo אחרי הניקוי, היכנס ל:
echo http://31.97.129.5:8081
echo.
echo ותראה:
echo ✓ "בהמתנה לתשובה" בתפריט הצדדי
echo ✓ כפתור "צור טיוטה" סגול בתשובות
echo.
echo ================================================
echo.
echo לחץ Enter לפתוח את האתר בדפדפן...
pause >nul

start http://31.97.129.5:8081