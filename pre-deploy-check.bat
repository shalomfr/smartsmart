@echo off
chcp 65001 >nul
cls
echo ================================================
echo      בדיקה לפני העלאה
echo ================================================
echo.

echo [1] בודק קבצים קריטיים...
echo ===========================
if not exist "src\contexts\AuthContext.jsx" echo חסר: AuthContext.jsx & goto error
if not exist "backend\server.js" echo חסר: server.js & goto error
if not exist "src\pages\PendingReplies.jsx" echo חסר: PendingReplies.jsx & goto error
if not exist "package.json" echo חסר: package.json & goto error
echo ✓ כל הקבצים קיימים

echo.
echo [2] בודק תוכן קבצים...
echo =======================
findstr /C:"admin" backend\server.js >nul || echo אזהרה: אין משתמש admin
findstr /C:"בהמתנה לתשובה" src\pages\Layout.jsx >nul || echo אזהרה: חסר בהמתנה לתשובה
findstr /C:"צור טיוטה" src\pages\Inbox.jsx >nul || echo אזהרה: חסר כפתור טיוטה

echo.
echo [3] בודק חיבור לשרת...
echo =======================
ping -n 1 31.97.129.5 >nul && echo ✓ השרת זמין || echo ✗ אין חיבור לשרת & goto error

echo.
echo [4] בודק מקום בשרת...
echo ======================
ssh root@31.97.129.5 "df -h | grep -E '(/$|/home)'" 2>nul || echo אזהרה: לא יכול לבדוק מקום

echo.
echo ================================================
echo ✅ הכל מוכן להעלאה!
echo.
echo הפעל: START-FRESH.bat
echo ================================================
echo.
pause
exit /b 0

:error
echo.
echo ❌ יש בעיות! תקן אותן לפני ההעלאה.
echo.
pause
exit /b 1