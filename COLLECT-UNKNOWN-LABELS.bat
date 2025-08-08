@echo off
chcp 65001 >nul
echo ================================================
echo      איסוף תוויות עבריות לא מזוהות
echo ================================================
echo.

echo [1] מעלה קובץ מעודכן עם מילון מורחב...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [2] מפעיל מחדש את השרת...
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [3] ממתין לאתחול...
timeout /t 3 >nul

echo.
echo ================================================
echo הוראות:
echo 1. פתח את האתר: http://31.97.129.5:8081
echo 2. עבור על כל המיילים שלך
echo 3. חזור לכאן לראות תוויות לא מזוהות
echo ================================================
echo.
echo לחץ Enter להציג תוויות לא מזוהות...
pause >nul

echo.
echo === תוויות לא מזוהות ===
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 200 | grep 'UNKNOWN_LABEL' | sort | uniq"

echo.
echo ================================================
echo אם אתה רואה תוויות כמו:
echo   [UNKNOWN_LABEL] "&BdXXXXX-" - Please add to dictionary
echo.
echo שלח לי את הרשימה ותגיד לי מה כל תווית אומרת בעברית!
echo ================================================
pause