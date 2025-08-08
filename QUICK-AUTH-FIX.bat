@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *          פתרון מהיר לבעיית כניסה               *
echo ****************************************************
echo.

echo בודק איך עובד האימות...
echo ========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -B5 -A15 'JWT_SECRET\\|mockUsers\\|testUsers' server.js"

echo.
echo ****************************************************
echo *               פתרונות אפשריים                   *
echo ****************************************************
echo.
echo 1. נסה את החשבון של המייל האמיתי שלך
echo    (אם הגדרת בהגדרות המייל)
echo.
echo 2. אם אתה רוצה רק לבדוק את הטיוטות,
echo    נסה לגשת ישירות ל:
echo.
echo    http://31.97.129.5:8082/#/Inbox?folder=drafts
echo    או
echo    http://31.97.129.5:8082/#/PendingReplies
echo.
echo 3. הפעל: CHECK-AUTH-TYPE.bat
echo    כדי לראות איזה סוג אימות מוגדר
echo.
echo ****************************************************
echo.
pause