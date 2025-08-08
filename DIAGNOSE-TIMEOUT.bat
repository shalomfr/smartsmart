@echo off
chcp 65001 >nul
cls
color 0C
echo ════════════════════════════════════════════════════
echo          אבחון בעיית Connection Timeout
echo ════════════════════════════════════════════════════
echo.

echo 🔍 בודק חיבור בסיסי...
ping -n 1 31.97.129.5 >nul 2>&1
if %errorlevel%==0 (
    echo ✅ יש חיבור לשרת
) else (
    echo ❌ אין חיבור לשרת כלל!
    goto no_connection
)

echo.
echo 🔍 בודק מה רץ על השרת...
ssh root@31.97.129.5 "echo 'שירותים רצים:' && pm2 list | grep -E 'online.*site' && echo && echo 'פורטים פתוחים:' && netstat -tlnp | grep LISTEN | grep -E '(80|443|8080|8081|8082|4000)' | awk '{print $4}' | sort -u"

echo.
echo ════════════════════════════════════════════════════
echo              🚨 האבחון שלך 🚨
echo ════════════════════════════════════════════════════
echo.
echo כנראה הספק שלך חוסם פורטים לא סטנדרטיים!
echo.
echo 📌 פתרונות מומלצים לפי סדר:
echo.
echo 1. השתמש ב-VPN:
echo    - הורד ProtonVPN / Windscribe (חינם)
echo    - התחבר ונסה שוב
echo.
echo 2. נסה מרשת אחרת:
echo    - חבר את המחשב לנקודה חמה מהטלפון
echo    - או נסה מרשת של חבר
echo.
echo 3. נסה פורטים אחרים שפתוחים:
echo    http://31.97.129.5:8080
echo    http://31.97.129.5:8081
echo    http://31.97.129.5
echo.
echo ════════════════════════════════════════════════════
echo.
pause
exit

:no_connection
echo.
echo ════════════════════════════════════════════════════
echo           ❌ אין חיבור לשרת בכלל! ❌
echo ════════════════════════════════════════════════════
echo.
echo בדוק:
echo 1. האם יש לך אינטרנט?
echo 2. האם השרת פועל?
echo 3. נסה לפנות לבעל השרת
echo.
pause