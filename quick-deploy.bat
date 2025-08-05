@echo off
REM ==========================================
REM Quick Deploy - Simple and Fast
REM ==========================================

echo Quick deployment starting...

REM Git operations
git add . 2>nul
git commit -m "Quick update %date% %time%" 2>nul
git push origin main --force 2>nul

REM Deploy to server
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm install && npm run build && cd backend && npm install && pm2 restart all"

echo.
echo Deployment complete!
echo Check status: ssh root@31.97.129.5 "pm2 status"
echo.
pause