@echo off
REM ==========================================
REM Test Everything - בדיקה מקיפה
REM ==========================================

echo.
echo ===== בדיקת מערכת מלאה =====
echo.

echo [1] בודק חיבור SSH...
ssh root@31.97.129.5 "echo 'חיבור תקין!'" || goto :error

echo.
echo [2] בודק סטטוס PM2...
ssh root@31.97.129.5 "pm2 status"

echo.
echo [3] בודק פורטים פתוחים...
ssh root@31.97.129.5 "netstat -tlnp | grep -E '3003|8080|80'"

echo.
echo [4] בודק Nginx...
ssh root@31.97.129.5 "nginx -t && echo 'Nginx תקין!'"

echo.
echo [5] בודק API ישירות (פורט 3003)...
curl -s http://31.97.129.5:3003/api/app/login && echo. || echo API ישיר לא זמין

echo.
echo [6] בודק API דרך Nginx...
curl -s http://31.97.129.5/api/app/login && echo. || echo API דרך Nginx לא זמין

echo.
echo [7] בודק Frontend...
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://31.97.129.5

echo.
echo ===== סיום בדיקות =====
echo.
echo אם כל הבדיקות עברו, האתר אמור לעבוד ב:
echo http://31.97.129.5
echo.
echo פרטי כניסה:
echo שם משתמש: admin
echo סיסמה: 123456
echo.
pause
exit /b 0

:error
echo.
echo [שגיאה] החיבור נכשל!
echo.
pause
exit /b 1