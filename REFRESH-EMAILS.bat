@echo off
echo ================================================
echo   רענון מיילים ב-site2
echo ================================================
echo.

echo [1] מנקה את ה-sessions...
ssh root@31.97.129.5 "pm2 restart site2-backend && echo 'Backend restarted'"

echo.
echo [2] מנקה cache של PM2...
ssh root@31.97.129.5 "pm2 flush site2-backend"

echo.
echo ================================================
echo   עכשיו באתר:
echo ================================================
echo.
echo 1. לחץ F12 לפתוח כלי פיתוח
echo 2. לחץ ימני על כפתור הרענון
echo 3. בחר "Empty Cache and Hard Reload"
echo.
echo או:
echo.
echo 1. התנתק מהאפליקציה (logout)
echo 2. סגור את הדפדפן לגמרי
echo 3. פתח מחדש והתחבר
echo 4. פתח מייל חדש (לא מייל שכבר פתחת)
echo.
pause