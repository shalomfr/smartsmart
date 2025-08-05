@echo off
echo ===== בודק סטטוס GitHub Action =====
echo.

echo פותח את דף ה-Actions...
start https://github.com/shalomfr/smartsmart/actions

echo.
echo בינתיים בודק את האתר...
echo.
timeout /t 5 /nobreak >nul

echo סטטוס האתר:
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo טיפים:
echo - לחץ על הפריסה האחרונה כדי לראות לוגים
echo - סימן ירוק = הצלחה
echo - סימן אדום = כשלון (בדוק את הלוגים)
echo - סימן צהוב = עדיין רץ
echo.
pause