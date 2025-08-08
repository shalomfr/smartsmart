@echo off
chcp 65001 >nul
cls
echo ================================================
echo      בדיקה מעמיקה של השרת
echo ================================================
echo.

echo [1] בודק אם הקבצים בשרת...
echo ==============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'Layout.jsx:' && grep 'בהמתנה לתשובה' Layout.jsx || echo 'לא נמצא בקובץ!'"
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'Inbox.jsx:' && grep 'צור טיוטה' Inbox.jsx || echo 'לא נמצא בקובץ!'"
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'PendingReplies.jsx:' && ls -la PendingReplies.jsx || echo 'הקובץ לא קיים!'"

echo.
echo [2] בודק תאריכי קבצים...
echo =========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && ls -la Layout.jsx Inbox.jsx"

echo.
echo [3] בודק את הבנייה האחרונה...
echo ==============================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && ls -la dist/index.html"

echo.
echo [4] בודק תהליכים רצים...
echo ========================
ssh root@31.97.129.5 "pm2 list"

echo.
echo [5] בודק שגיאות אחרונות...
echo ==========================
ssh root@31.97.129.5 "pm2 logs --lines 5"

echo.
pause