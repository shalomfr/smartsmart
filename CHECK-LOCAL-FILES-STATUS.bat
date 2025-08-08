@echo off
chcp 65001 >nul
cls
color 0E
echo ================================================
echo      בדיקת קבצים מקומיים
echo ================================================
echo.

echo [1] בודק AuthContext.jsx...
echo ============================
echo חיפוש URL:
findstr /n "http://31.97.129.5:4000" src\contexts\AuthContext.jsx
echo.
echo חיפוש login endpoint:
findstr /n "/api/app/login" src\contexts\AuthContext.jsx

echo.
echo [2] בודק backend/server.js...
echo ==============================
echo משתמשים:
findstr /n "admin.*123456" backend\server.js
echo.
echo Endpoints:
findstr /n "/api/app/login" backend\server.js

echo.
echo [3] בודק קבצי API...
echo ====================
for %%f in (src\api\*.js) do (
    echo.
    echo בודק %%f:
    findstr /n "API_URL.*=.*'http://31.97.129.5:4000'" %%f
)

echo.
echo [4] מסקנה...
echo =============
echo אם כל הקבצים מכוונים ל-31.97.129.5:4000 - הבעיה בשרת!
echo.
pause