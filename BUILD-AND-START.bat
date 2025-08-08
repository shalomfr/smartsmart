@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

echo ==================================================
echo   בנייה והפעלה - Backend (4000) + Frontend (5173)
echo ==================================================
echo.

REM בדיקת Node ו-NPM
where node >nul 2>&1
if errorlevel 1 (
  echo [שגיאה] Node.js לא נמצא ב-PATH. התקן Node.js ונסה שוב.
  echo https://nodejs.org
  pause
  exit /b 1
)
where npm >nul 2>&1
if errorlevel 1 (
  echo [שגיאה] npm לא נמצא ב-PATH. התקן Node.js ונסה שוב.
  pause
  exit /b 1
)

REM התחלת ה-Backend
echo [1/3] התקנה והפעלה של Backend (פורט 4000)...
pushd backend
if not exist node_modules (
  echo [INFO] מתקין תלויות Backend...
  call npm install --silent
)
REM מפעיל את השרת בחלון נפרד
start "backend-4000" cmd /c "npm start"
popd

REM המתנה קצרה לעלייה
timeout /t 3 /nobreak >nul

REM בניית Frontend
echo [2/3] התקנת תלויות Frontend...
if not exist node_modules (
  call npm install --silent
)

echo [3/3] בניית Frontend (vite build)...
call npm run build

echo מפעיל תצוגה מקדימה (vite preview) על פורט 5173...
start "frontend-5173" cmd /c "npm run preview -- --host --port 5173"

REM המתנה קצרה ופתיחת דפדפן
timeout /t 3 /nobreak >nul
start http://localhost:5173

echo.
echo =============================================
echo Frontend: http://localhost:5173
echo Backend : http://localhost:4000
echo Proxy   : בקשות ‎/api‎ מופנות ל-Backend דרך Vite
echo =============================================
echo.
echo לשים לב: סגירת החלון הזה לא תסגור את השרתים שנפתחו בחלונות נפרדים.
echo ניתן לעצור אותם מהחלונות שנפתחו או דרך Task Manager.
echo.
pause
exit /b 0


