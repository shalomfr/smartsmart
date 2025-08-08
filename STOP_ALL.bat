@echo off
chcp 65001 >nul
echo ==============================
echo   עצירת שרתים (Node/Vite)
echo ==============================
echo.

REM נסה לסגור חלונות שפתחנו בשם
for /f "tokens=2 delims==" %%i in ('tasklist /v /fi "imagename eq cmd.exe" ^| findstr /i "backend-4000 backend-dev-4000 frontend-5173 frontend-dev-5173"') do (
  REM אין דרך אמינה כאן לשייך ישירות, אז נ fallback להריגת node
  REM אפשר לשפר לשימוש ב-handle/powershell לפי pid מ-window title
)

REM הרג תהליכי node כלליים (אם אין תהליכים אחרים חשובים)
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM npm.exe >nul 2>&1

echo הופסק.
pause
exit /b 0


