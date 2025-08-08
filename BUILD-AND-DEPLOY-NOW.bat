@echo off
chcp 65001 >nul
echo ================================================
echo      בניה והעלאה מחדש
echo ================================================
echo.

echo [1] עוצר את השרתים...
ssh root@31.97.129.5 "pm2 stop site2-frontend site2-backend"

echo.
echo [2] מוחק build ישן...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && rm -rf dist/"

echo.
echo [3] בונה מחדש...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [4] מפעיל מחדש...
ssh root@31.97.129.5 "pm2 start site2-frontend && pm2 start site2-backend"

echo.
echo [5] בודק שנבנה נכון...
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && echo 'מחפש בהמתנה לתשובה:' && grep -l 'בהמתנה לתשובה' *.js | head -3"

echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && echo 'מחפש צור טיוטה:' && grep -l 'צור טיוטה' *.js | head -3"

echo.
echo ================================================
echo   הבנייה הושלמה! 
echo   עכשיו פתח חלון חדש ב: http://31.97.129.5:8081
echo ================================================
echo.
pause