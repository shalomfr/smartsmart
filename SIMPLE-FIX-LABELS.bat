@echo off
echo ================================================
echo   תיקון פשוט לתוויות
echo ================================================
echo.
echo מתחבר לשרת...
echo.
echo ברגע שתתחבר, העתק והדבק את הפקודות הבאות:
echo.
echo 1. cd /home/emailapp/site2/backend
echo 2. nano server.js
echo 3. חפש (Ctrl+W): x-gm-labels
echo 4. תקן את הקוד לפי ההוראות
echo 5. שמור: Ctrl+X, Y, Enter
echo 6. pm2 restart site2-backend
echo.
pause

ssh root@31.97.129.5