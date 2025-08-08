@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *      תיקון בעיית שמירת הגדרות מייל             *
echo ****************************************************
echo.

echo [1] בודק את settingsAPI.js המקומי...
echo =====================================
type src\api\settingsAPI.js | findstr /n "API_URL save"

echo.
echo [2] בודק endpoints בשרת...
echo ==========================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && grep -n '/settings' server.js || echo 'אין endpoints להגדרות!'"

echo.
echo [3] בודק את קובץ settingsAPI בשרת...
echo =====================================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/src/api && grep -n 'settings/save' settingsAPI.js"

echo.
echo [4] מתקן את settingsAPI.js...
echo ==============================
powershell -Command "(Get-Content src\api\settingsAPI.js) -replace 'const API_URL = .*', 'const API_URL = ''http://31.97.129.5:4000'';' -replace 'fetch\(`\$\{API_URL\}', 'fetch(`http://31.97.129.5:4000/api' | Set-Content src\api\settingsAPI.js"

echo.
echo [5] מעלה לשרת...
echo =================
scp src/api/settingsAPI.js root@31.97.129.5:/home/emailapp/email-prod/src/api/

echo.
echo [6] בודק שה-Backend תומך בהגדרות...
echo ====================================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/backend && grep -c 'app.post.*settings' server.js || echo '0'"

echo.
echo [7] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && npm run build"

echo.
echo [8] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart email-frontend email-backend"

echo.
echo ****************************************************
echo *              הערה חשובה!                       *
echo ****************************************************
echo.
echo אם אתה מנסה להתחבר עם מייל אמיתי:
echo - Gmail: צריך סיסמת אפליקציה (לא הסיסמה הרגילה)
echo - Outlook: הסיסמה הרגילה אמורה לעבוד
echo.
echo או פשוט השתמש בכניסה עם:
echo admin / 123456
echo.
pause