@echo off
chcp 65001 >nul
cls
color 0E
echo ================================================
echo      תיקון כל ה-URLs בקבצים המקומיים
echo ================================================
echo.

echo [1] מתקן את AuthContext.jsx...
echo ===============================
powershell -Command "(Get-Content src\contexts\AuthContext.jsx) -replace 'localhost:3001', '31.97.129.5:5000' -replace 'localhost:4000', '31.97.129.5:5000' | Set-Content src\contexts\AuthContext.jsx"

echo.
echo [2] מתקן את קבצי ה-API...
echo ==========================
echo מתקן settingsAPI.js...
powershell -Command "if (Test-Path src\api\settingsAPI.js) { (Get-Content src\api\settingsAPI.js) -replace 'http://localhost:4000', 'http://31.97.129.5:5000' | Set-Content src\api\settingsAPI.js }"

echo.
echo מתקן realEmailAPI.js...
powershell -Command "if (Test-Path src\api\realEmailAPI.js) { (Get-Content src\api\realEmailAPI.js) -replace 'http://localhost:4000', 'http://31.97.129.5:5000' | Set-Content src\api\realEmailAPI.js }"

echo.
echo מתקן claudeAPI.js...
powershell -Command "if (Test-Path src\api\claudeAPI.js) { (Get-Content src\api\claudeAPI.js) -replace 'http://localhost:4000', 'http://31.97.129.5:5000' | Set-Content src\api\claudeAPI.js }"

echo.
echo [3] מתקן את vite.config.js...
echo ==============================
(
echo import { defineConfig } from 'vite'
echo import react from '@vitejs/plugin-react'
echo.
echo export default defineConfig({
echo   plugins: [react()],
echo   server: {
echo     proxy: {
echo       '/api': {
echo         target: 'http://localhost:5000',
echo         changeOrigin: true
echo       }
echo     }
echo   }
echo })
) > vite.config.js.new
move /Y vite.config.js.new vite.config.js

echo.
echo [4] מתקן את backend/server.js...
echo =================================
powershell -Command "(Get-Content backend\server.js) -replace 'const PORT = 4000', 'const PORT = 5000' | Set-Content backend\server.js"

echo.
echo ================================================
echo   תיקונים הושלמו!
echo   עכשיו הפעל: CREATE-NEW-SITE3.bat
echo ================================================
echo.
pause