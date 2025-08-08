@echo off
chcp 65001 >nul
cls
color 0E
echo ================================================
echo         אבחון מלא של המערכת
echo ================================================
echo.

echo [1] Frontend Status:
echo ===================
ssh root@31.97.129.5 "pm2 list | grep site2-frontend"

echo.
echo [2] Backend Status:
echo ==================
ssh root@31.97.129.5 "pm2 list | grep site2-backend"

echo.
echo [3] פורטים פתוחים:
echo ==================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)' || echo 'אין פורטים פתוחים!'"

echo.
echo [4] בדיקת תקשורת Backend:
echo ==========================
ssh root@31.97.129.5 "curl -s http://localhost:4000/api/health || echo 'Backend לא מגיב!'"

echo.
echo [5] קבצי Frontend:
echo ==================
ssh root@31.97.129.5 "ls -la /home/emailapp/site2/dist/ | head -5"

echo.
echo ================================================
echo              סיכום בעיות
echo ================================================
echo.
echo אם ראית "errored" ב-Frontend - הפעל: FIX-FRONTEND-ERROR.bat
echo אם אין פורטים פתוחים - הפעל: COMPLETE-FIX.bat
echo אם Backend לא מגיב - הפעל: FIX-BACKEND-NOW.bat
echo.
echo ================================================
echo.
pause