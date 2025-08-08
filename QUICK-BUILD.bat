@echo off
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build && pm2 restart site2-backend site2-frontend && echo 'Done!'"