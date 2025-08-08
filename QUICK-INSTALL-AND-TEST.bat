@echo off
echo ================================================
echo       פענוח אוטומטי של תוויות עבריות
echo ================================================
echo.

echo [1] התקנת UTF7...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && npm install utf7 --save"

echo.
echo [2] העלאת קוד...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js

echo.
echo [3] הפעלה מחדש...
ssh root@31.97.129.5 "pm2 restart site2-backend && sleep 3 && pm2 logs site2-backend --lines 30"

echo.
echo ================================================
echo בדוק עכשיו באתר - כל התוויות בעברית!
echo ================================================
pause