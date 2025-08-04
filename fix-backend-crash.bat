@echo off
echo =============================================
echo   🔧 תיקון Backend שקורס
echo =============================================
echo.

echo התחבר לשרת והעתק את הפקודות הבאות:
echo.
echo ssh root@31.97.129.5
echo.
echo אחרי שהתחברת, הרץ את הפקודות האלה אחת אחת:
echo.
echo # 1. עצור את הכל
echo pm2 delete all
echo.
echo # 2. בדוק את הבעיה
echo cd /home/emailapp/email-app/backend
echo ls -la
echo cat .env
echo.
echo # 3. צור קובץ .env חדש
echo echo "PORT=3002" > .env
echo.
echo # 4. בדוק שיש את כל הקבצים
echo ls server.js
echo ls package.json
echo.
echo # 5. התקן תלויות
echo npm install
echo.
echo # 6. נסה להריץ ישירות (לראות שגיאות)
echo node server.js
echo.
echo # אם זה עובד, הקש Ctrl+C ואז:
echo.
echo # 7. הפעל עם PM2
echo pm2 start server.js --name email-app-backend
echo.
echo # 8. הפעל גם את ה-frontend
echo cd /home/emailapp/email-app
echo pm2 serve dist 8080 --name email-app-frontend --spa
echo.
echo # 9. שמור ובדוק
echo pm2 save
echo pm2 status
echo.
pause