@echo off
chcp 65001 >nul
echo ================================================
echo     בדיקת מבנה site2 בשרת
echo ================================================
echo.

echo מבנה התיקיות הנוכחי:
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2 && find . -type d -name 'pages' | head -20"

echo.
echo תוכן התיקייה הראשית:
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2 && ls -la"

echo.
echo חיפוש קבצי pages:
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2 && find . -name 'Layout.jsx' -o -name 'Inbox.jsx' | head -10"

echo.
pause