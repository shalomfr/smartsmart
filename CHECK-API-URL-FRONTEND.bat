@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *      בדיקת URL של API ב-Frontend               *
echo ****************************************************
echo.

echo [1] בודק מה כתוב ב-AuthContext המקומי...
echo =========================================
type src\contexts\AuthContext.jsx | findstr /n "API_URL"

echo.
echo [2] בודק מה הועלה לשרת...
echo ===========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/contexts && grep -n 'API_URL' AuthContext.jsx 2>/dev/null || echo 'הקובץ לא נמצא'"

echo.
echo [3] בודק בקבצים הבנויים...
echo ===========================
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && grep -h 'api/app/login' *.js | head -3"

echo.
echo [4] בודק Network בדפדפן...
echo ==========================
echo.
echo פתח את כלי הפיתוח בדפדפן (F12)
echo עבור לכרטיסיית Network
echo נסה להתחבר ותראה לאיזה URL הוא שולח
echo.
echo זה צריך להיות:
echo http://31.97.129.5:4000/api/app/login
echo.
pause