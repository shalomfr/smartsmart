@echo off
echo ===== תיקון מלא של האתר =====
echo.

echo [1] מתחבר לשרת ומתקן הכל...
echo ===============================

ssh root@31.97.129.5 "cd /home/emailapp/email-app && echo '[1/8] מנקה קבצים ישנים...' && rm -rf node_modules dist package-lock.json && echo '[2/8] מנקה npm cache...' && npm cache clean --force && echo '[3/8] מתקין חבילות...' && npm install --legacy-peer-deps && echo '[4/8] מתקין vite...' && npm install vite @vitejs/plugin-react --save-dev && echo '[5/8] בונה את האתר...' && npm run build && echo '[6/8] בודק שנוצרה תיקיית dist...' && ls -la dist/ | head -5 && echo '[7/8] מפעיל מחדש שירותים...' && pm2 restart all && nginx -s reload && echo '[8/8] מציג סטטוס...' && pm2 status"

echo.
echo [2] בודק את האתר...
echo ====================
timeout /t 5 /nobreak >nul

curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo ===== הושלם! =====
echo.
echo לך ל: http://31.97.129.5
echo.
echo כניסה:
echo - משתמש: admin
echo - סיסמה: 123456
echo.
echo אם עדיין לא עובד, הרץ: PERFECT-INSTALL.bat
echo.
pause