@echo off
chcp 65001 >nul
cls
echo ================================================
echo      בדיקת קבצים במחשב המקומי
echo ================================================
echo.

echo בודק קבצים מקומיים...
echo.

echo [1] Layout.jsx:
findstr /n "בהמתנה לתשובה" src\pages\Layout.jsx 2>nul || echo לא נמצא!

echo.
echo [2] Inbox.jsx:
findstr /n "צור טיוטה" src\pages\Inbox.jsx 2>nul || echo לא נמצא!

echo.
echo [3] PendingReplies.jsx:
if exist src\pages\PendingReplies.jsx (
    echo קיים!
    dir src\pages\PendingReplies.jsx
) else (
    echo הקובץ לא קיים!
)

echo.
echo [4] index.jsx:
findstr /n "PendingReplies" src\pages\index.jsx 2>nul || echo לא נמצא!

echo.
echo ================================================
echo אם משהו "לא נמצא" - הקבצים לא מעודכנים!
echo ================================================
echo.
pause