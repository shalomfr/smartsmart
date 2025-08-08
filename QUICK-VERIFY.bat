@echo off
chcp 65001 >nul
echo בודק שהקבצים הועלו...
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'Layout.jsx:' && grep -n 'בהמתנה לתשובה' Layout.jsx | head -1"
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'Inbox.jsx:' && grep -n 'צור טיוטה' Inbox.jsx | head -1"
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'PendingReplies.jsx:' && ls -la PendingReplies.jsx"
echo.
echo אם אתה רואה את כל השורות - הכל בסדר!
echo.
pause