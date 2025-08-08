@echo off
chcp 65001 >nul
cls
echo ================================================
echo      סריקת כל הקבצים החשובים
echo ================================================
echo.

echo === בודק קבצי API ===
echo =====================
echo.
echo settingsAPI.js:
type src\api\settingsAPI.js | findstr /n "apiUrl API"
echo.
echo realEmailAPI.js:
type src\api\realEmailAPI.js | findstr /n "apiUrl API"
echo.
echo claudeAPI.js:
type src\api\claudeAPI.js | findstr /n "apiUrl API"

echo.
echo === בודק קבצי Context ===
echo =========================
type src\contexts\AuthContext.jsx | findstr /n "API_URL login"

echo.
echo === בודק Backend ===
echo ====================
echo Ports:
type backend\server.js | findstr /n "PORT listen"
echo.
echo Users:
type backend\server.js | findstr /n "APP_USERS username password"

echo.
echo === בודק קבצי הגדרות ===
echo ========================
echo package.json:
type package.json | findstr /n "proxy"
echo.
echo vite.config.js:
type vite.config.js

echo.
pause