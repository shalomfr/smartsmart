@echo off
chcp 65001 >nul
cls
echo ================================================
echo     בדיקה מהירה - האם הקבצים בשרת?
echo ================================================
echo.

echo בודק קובץ Layout.jsx בשרת...
echo -------------------------------
ssh root@31.97.129.5 "grep -A2 -B2 'בהמתנה לתשובה' /home/emailapp/site2/src/pages/Layout.jsx || echo 'לא נמצא!'"

echo.
echo בודק קובץ Inbox.jsx בשרת...
echo -----------------------------
ssh root@31.97.129.5 "grep -A2 -B2 'צור טיוטה' /home/emailapp/site2/src/pages/Inbox.jsx || echo 'לא נמצא!'"

echo.
echo בודק אם PendingReplies.jsx קיים...
echo -----------------------------------
ssh root@31.97.129.5 "ls -la /home/emailapp/site2/src/pages/PendingReplies.jsx 2>&1 || echo 'הקובץ לא קיים!'"

echo.
echo ================================================
echo אם אתה רואה "לא נמצא" - הקבצים לא הועלו!
echo ================================================
echo.
pause