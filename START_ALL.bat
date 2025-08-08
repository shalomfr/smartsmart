@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

echo ============================================
echo   START_ALL - פותח Backend + Frontend Dev
echo ============================================
echo.

REM סוגר תהליכי node ישנים (אופציונלי)
REM taskkill /F /IM node.exe >nul 2>&1

REM Backend - Dev (צפייה חמה אם יש nodemon)
pushd backend
if not exist node_modules (
  echo [Backend] מתקין תלויות...
  call npm install --silent
)
start "backend-dev-4000" cmd /c "npm start"
popd

timeout /t 2 /nobreak >nul

REM Frontend - Dev
if not exist node_modules (
  echo [Frontend] מתקין תלויות...
  call npm install --silent
)
start "frontend-dev-5173" cmd /c "npm run dev"

timeout /t 2 /nobreak >nul
start http://localhost:5173

echo.
echo רץ במצב פיתוח:
echo   Backend : http://localhost:4000
echo   Frontend: http://localhost:5173
echo.
pause
exit /b 0


