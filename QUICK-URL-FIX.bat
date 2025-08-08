@echo off
cls
echo ══════════════════════════════════════════
echo     תיקון מהיר - 30 שניות
echo ══════════════════════════════════════════
echo.

REM תיקון מהיר של AuthContext
echo מתקן את קובץ הכניסה...
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace 'fetch\(`.*login.*`', 'fetch(`http://31.97.129.5:4000/api/app/login`' | Set-Content src\contexts\AuthContext.jsx"

echo מעלה לשרת...
scp src/contexts/AuthContext.jsx root@31.97.129.5:/home/emailapp/site2/src/contexts/

echo בונה מחדש...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build && pm2 restart site2-frontend"

echo.
echo ══════════════════════════════════════════
echo זהו! נסה עכשיו (נקה מטמון קודם)
echo http://31.97.129.5:8082
echo admin / 123456
echo ══════════════════════════════════════════
pause