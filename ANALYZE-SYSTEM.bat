@echo off
chcp 65001 >nul
cls
echo ================================================
echo         ניתוח מערכת מלא
echo ================================================
echo.

echo [1] מבנה התיקיות...
echo ====================
dir /B src\pages
echo.
dir /B src\api
echo.
dir /B src\contexts

echo.
echo [2] בודק קבצי הגדרות...
echo ========================
type package.json | findstr "name version scripts"
echo.
type vite.config.js

echo.
echo [3] בודק Backend...
echo ==================
type backend\package.json | findstr "name version scripts"
echo.
findstr /n "app.listen PORT" backend\server.js

echo.
echo [4] בודק נתיבי API...
echo ====================
findstr /n "apiUrl API_URL fetch" src\api\*.js src\contexts\*.jsx

echo.
pause