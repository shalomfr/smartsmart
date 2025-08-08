@echo off
echo ================================================
echo   תיקון בעיית הסלאש בתוויות
echo ================================================
echo.

echo [1] יוצר סקריפט תיקון...
(
echo const fs = require('fs'^);
echo let content = fs.readFileSync('server.js', 'utf8'^);
echo.
echo // מוסיף טיפול בסלאש בסוף התוויות
echo const oldCode = "const upperLabel = label.toUpperCase(^);";
echo const newCode = `// נקה סלאש מהסוף
echo                   label = label.replace(/\\\\$/, ''^);
echo                   const upperLabel = label.toUpperCase(^);`;
echo.
echo if (content.includes(oldCode^)^) {
echo     content = content.replace(oldCode, newCode^);
echo     fs.writeFileSync('server.js', content^);
echo     console.log('Fixed slash issue!'^);
echo } else {
echo     console.log('Code already fixed or not found'^);
echo }
) > temp-fix-slash.js

echo.
echo [2] מעלה ומריץ בשרת...
scp temp-fix-slash.js root@31.97.129.5:/home/emailapp/site2/backend/
del temp-fix-slash.js

ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && node temp-fix-slash.js && rm temp-fix-slash.js && pm2 restart site2-backend"

echo.
echo [3] בודק סטטוס...
timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "pm2 status | grep site2-backend"

echo.
echo ================================================
echo   ✅ התיקון הושלם!
echo ================================================
echo.
echo עכשיו:
echo 1. רענן את הדף (Ctrl+F5)
echo 2. התוויות אמורות להופיע בעברית
echo.
echo אם עדיין לא עובד, נסה:
echo - התנתק והתחבר מחדש לאפליקציה
echo - נקה cookies של הדפדפן
echo.
pause