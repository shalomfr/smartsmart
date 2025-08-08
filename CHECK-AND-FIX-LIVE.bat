@echo off
echo ================================================
echo     בדיקה ותיקון בזמן אמת
echo ================================================
echo.

echo [1] בודק חיבור לשרת...
ping -n 1 31.97.129.5 >nul 2>&1
if errorlevel 1 (
    echo [X] אין חיבור לשרת!
    echo בדוק את החיבור לאינטרנט או כתובת IP
    pause
    exit
)
echo [V] חיבור תקין

echo.
echo [2] מתחבר לשרת ובודק מה קורה...
echo ------------------------------------------------

ssh root@31.97.129.5 "
echo '=== בדיקת PM2 ==='
pm2 list

echo
echo '=== בדיקת תיקיית dist ==='
ls -la /home/emailapp/email-app/dist/ 2>&1

echo
echo '=== בדיקת Backend Port ==='
netstat -tlnp | grep 3001

echo
echo '=== בדיקת Nginx ==='
systemctl status nginx | grep Active

echo
echo '=== בדיקת לוגים של Backend ==='
pm2 logs backend --lines 5

echo
echo '=== נסיון תיקון מהיר ==='
cd /home/emailapp/email-app

# אם אין dist, בונה
if [ ! -d dist ]; then
    echo 'אין תיקיית dist! בונה את האתר...'
    npm install vite --save-dev 2>/dev/null
    npm run build
fi

# מוודא שהבקאנד רץ
pm2 describe backend >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo 'Backend לא רץ! מפעיל...'
    cd backend
    echo 'PORT=3001' > .env
    pm2 start server.js --name backend
    cd ..
fi

# מוודא שהפרונטאנד רץ
pm2 describe frontend >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo 'Frontend לא רץ! מפעיל...'
    pm2 serve dist 8080 --name frontend --spa
fi

# בודק Nginx
if ! systemctl is-active --quiet nginx; then
    echo 'Nginx לא פעיל! מפעיל...'
    systemctl start nginx
fi

echo
echo '=== בדיקה סופית ==='
pm2 list
echo
curl -I http://localhost 2>&1 | head -5
"

echo.
echo ================================================
echo     בדיקת גישה מהמחשב שלך
echo ================================================
echo.

echo בודק http://31.97.129.5 ...
curl -s -o nul -w "Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo ================================================
echo     מה לעשות עכשיו?
echo ================================================
echo.
echo 1. אם ראית Status: 200 - האתר עובד! נסה לרענן (Ctrl+F5)
echo 2. אם ראית Status: 502 - הבקאנד לא רץ כמו שצריך
echo 3. אם ראית Status: 404 - האתר לא נבנה
echo 4. אם לא קיבלת תשובה - בעיית רשת או Nginx
echo.
echo תעתיק את כל הפלט ותשלח לי!
echo.
pause