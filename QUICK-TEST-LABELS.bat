@echo off
echo העלאה מהירה...
scp backend\server.js root@31.97.129.5:/home/emailapp/site2/backend/server.js
ssh root@31.97.129.5 "pm2 restart site2-backend && sleep 2 && pm2 logs site2-backend --lines 50"