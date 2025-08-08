@echo off
chcp 65001 >nul
echo ================================================
echo      בדיקה אמיתית של הבעיה
echo ================================================
echo.

echo [1] בודק אם הקבצים באמת הועלו נכון...
echo.
echo === Layout.jsx ===
ssh root@31.97.129.5 "grep -n 'בהמתנה לתשובה' /home/emailapp/site2/src/pages/Layout.jsx | head -5"

echo.
echo === Inbox.jsx ===
ssh root@31.97.129.5 "grep -n 'צור טיוטה' /home/emailapp/site2/src/pages/Inbox.jsx | head -5"

echo.
echo === PendingReplies.jsx ===
ssh root@31.97.129.5 "ls -la /home/emailapp/site2/src/pages/PendingReplies.jsx"

echo.
echo [2] בודק מתי נבנה לאחרונה...
ssh root@31.97.129.5 "cd /home/emailapp/site2 && ls -la dist/"

echo.
echo [3] בודק את הקבצים הבנויים...
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && grep -l 'בהמתנה לתשובה' *.js 2>/dev/null || echo 'לא נמצא בקבצים הבנויים!'"

echo.
echo [4] בודק תהליכי pm2...
ssh root@31.97.129.5 "pm2 list | grep site2"

echo.
pause