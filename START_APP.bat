@echo off
echo Starting Email App...
echo.

REM Kill old processes
taskkill /F /IM node.exe >nul 2>&1

REM Start Backend
cd backend
start /min cmd /c "C:\Program Files\nodejs\node.exe" server.js
cd ..

REM Wait a bit
timeout /t 3 /nobreak >nul

REM Start Frontend  
start /min cmd /c "C:\Program Files\nodejs\npm.cmd" run dev

REM Wait for everything to start
timeout /t 5 /nobreak >nul

REM Open browser
start http://localhost:5173

echo.
echo App is running!
echo Frontend: http://localhost:5173
echo Backend: http://localhost:3001
echo.
echo Press any key to continue...
pause >nul