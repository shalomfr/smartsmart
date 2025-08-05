@echo off
echo ===== בונה את האתר מחדש =====
echo.

echo דוחף לגיטהאב...
git add . && git commit -m "Rebuild" && git push --force

echo.
echo בונה את האתר בשרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && rm -rf dist && npm install && npm run build && pm2 restart all && systemctl restart nginx"

echo.
echo בודק...
timeout /t 3 /nobreak >nul
curl -s -o nul -w "Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo ===== הושלם! =====
echo http://31.97.129.5
echo משתמש: admin | סיסמה: 123456
echo.
pause