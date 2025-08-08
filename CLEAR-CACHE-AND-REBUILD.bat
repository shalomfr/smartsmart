@echo off
chcp 65001 >nul
echo ================================================
echo      ניקוי מטמון ובנייה מחדש
echo ================================================
echo.

set SERVER=31.97.129.5

echo [1] מנקה מטמון ובונה מחדש...
ssh root@%SERVER% "cd /home/emailapp/site2 && rm -rf dist node_modules/.cache && npm run build"

echo.
echo [2] מפעיל מחדש עם --update-env...
ssh root@%SERVER% "pm2 restart site2-backend site2-frontend --update-env"

echo.
echo [3] בודק שהתכונות החדשות קיימות...
echo.
ssh root@%SERVER% "cd /home/emailapp/site2 && echo '=== תיקייה בתפריט ===' && grep 'בהמתנה לתשובה' src/pages/Layout.jsx | head -2"
echo.
ssh root@%SERVER% "cd /home/emailapp/site2 && echo '=== כפתור צור טיוטה ===' && grep 'צור טיוטה' src/pages/Inbox.jsx | head -2"
echo.
ssh root@%SERVER% "cd /home/emailapp/site2 && echo '=== PendingReplies קיים ===' && ls -la src/pages/PendingReplies.jsx"

echo.
echo ================================================
echo חשוב! בדפדפן:
echo 1. לחץ Ctrl+F5 (רענון קשה)
echo 2. או פתח חלון גלישה בסתר/פרטית
echo 3. או נקה את כל המטמון של הדפדפן
echo ================================================
echo.
echo האתר: http://31.97.129.5:8081
echo.
pause