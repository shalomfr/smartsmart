@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

REM ================= פרמטרים =================
set SERVER=31.97.129.5
set USER=root
set REMOTE_DIR=/home/emailapp/site2
set BACKEND_NAME=site2-backend
set FRONTEND_NAME=site2-frontend

echo ================================================
echo   פריסה מלאה ל-%REMOTE_DIR% על %SERVER%
echo ================================================
echo.

REM בדיקת כלים
where ssh >nul 2>&1 || (echo [שגיאה] ssh לא זמין ב-PATH & pause & exit /b 1)
where scp >nul 2>&1 || (echo [שגיאה] scp לא זמין ב-PATH & pause & exit /b 1)

REM בניית Frontend מקומית
echo [1/5] מתקין תלויות Frontend מקומית (אם צריך)...
if not exist node_modules (
  call npm install --silent || (echo [שגיאה] npm install נכשל & exit /b 1)
)
echo [2/5] בונה Frontend מקומית (vite build)...
call npm run build || (echo [שגיאה] build נכשל & exit /b 1)

REM העלאת קבצי פרונט+בקאנד לשרת
echo [3/5] מעלה קבצים לשרת...
scp -r dist/* %USER%@%SERVER%:%REMOTE_DIR%/dist/ 2>nul
scp -r backend/* %USER%@%SERVER%:%REMOTE_DIR%/backend/ 2>nul
scp package.json %USER%@%SERVER%:%REMOTE_DIR%/package.json 2>nul
scp vite.config.js %USER%@%SERVER%:%REMOTE_DIR%/vite.config.js 2>nul

REM התקנות ובנייה בצד השרת + הפעלה
echo [4/5] מתקין ובונה על השרת ומפעיל שירותים...
ssh %USER%@%SERVER% "bash -lc 'set -e
  cd %REMOTE_DIR%
  echo Installing frontend packages...
  npm install --silent || true
  echo Building (already built locally) - skipping npm run build
  cd backend
  echo Installing backend packages...
  npm install --silent || true
  echo Restarting services with PM2...
  pm2 start server.js --name %BACKEND_NAME% 2>/dev/null || pm2 restart %BACKEND_NAME%
  cd ..
  pm2 serve dist 9000 --name %FRONTEND_NAME% --spa 2>/dev/null || pm2 restart %FRONTEND_NAME%
  pm2 save
'" || (echo [שגיאה] פעולת SSH נכשלה & exit /b 1)

REM בדיקות סטטוס
echo [5/5] בדיקת סטטוס בשרת...
ssh %USER%@%SERVER% "bash -lc 'pm2 list | grep -E "%BACKEND_NAME%|%FRONTEND_NAME%" && echo && curl -s -o /dev/null -w "HTTP %%{http_code}\n" http://localhost:9000'"

echo.
echo ✅ פריסה הושלמה: http://%SERVER%:8081 או ניהול דרך Nginx לפי התצורה
echo.
pause


