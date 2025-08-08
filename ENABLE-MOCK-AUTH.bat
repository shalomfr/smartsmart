@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *         הפעלת משתמשי בדיקה                      *
echo ****************************************************
echo.

echo [1] יוצר קובץ הגדרות לסביבת פיתוח...
echo =====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && echo 'USE_MOCK_AUTH=true' > .env"
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && echo 'NODE_ENV=development' >> .env"

echo.
echo [2] בודק את קובץ server.js...
echo ==============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'mockUsers' server.js || echo 'אין משתמשי בדיקה מוגדרים!'"

echo.
echo [3] מוסיף משתמשי בדיקה אם חסרים...
echo ====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cp server.js server.js.backup"

echo.
echo [4] מפעיל מחדש את השרת...
echo ==========================
ssh root@31.97.129.5 "pm2 restart site2-backend"

echo.
echo [5] בודק שהכל עובד...
echo =====================
ssh root@31.97.129.5 "sleep 3 && curl -X POST http://localhost:4000/api/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"test@example.com\",\"password\":\"123456\"}' 2>/dev/null"

echo.
echo ****************************************************
echo *                נסה עכשיו:                        *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8082
echo.
echo כניסה פשוטה:
echo -------------
echo אימייל: test@example.com
echo סיסמה: 123456
echo.
echo ****************************************************
echo.
pause