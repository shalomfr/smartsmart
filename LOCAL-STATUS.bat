@echo off
cls
echo ════════════════════════════════════════════════════
echo           סטטוס קבצים מקומיים
echo ════════════════════════════════════════════════════
echo.

echo [AuthContext.jsx]
echo -----------------
type src\contexts\AuthContext.jsx | findstr /n "fetch.*login" | findstr "4000"
if %errorlevel% == 0 (echo ✓ מכוון לפורט 4000) else (echo ✗ בעיה ב-URL!)

echo.
echo [Backend server.js]
echo -------------------
findstr "admin.*123456" backend\server.js >nul
if %errorlevel% == 0 (echo ✓ משתמש admin מוגדר) else (echo ✗ חסר משתמש admin!)

echo.
echo [API Files]
echo -----------
findstr "31.97.129.5:4000" src\api\*.js >nul
if %errorlevel% == 0 (echo ✓ API files מכוונים נכון) else (echo ✗ בעיה ב-API URLs!)

echo.
echo [Vite Config]
echo -------------
findstr "proxy" vite.config.js >nul
if %errorlevel% == 0 (echo ✓ Proxy מוגדר) else (echo ✗ אין proxy!)

echo.
echo ════════════════════════════════════════════════════
echo.
echo אם יש ✗ - הפעל: ULTIMATE-FIX-ALL.bat
echo.
pause