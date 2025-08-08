@echo off
chcp 65001 >nul
cls
color 0A
echo ════════════════════════════════════════════════════
echo          פתרון סופי - אתר חדש לגמרי
echo ════════════════════════════════════════════════════
echo.
echo זה ייצור אתר חדש על:
echo Frontend: http://31.97.129.5:5173
echo Backend: http://31.97.129.5:5000
echo.
echo המשך? (Ctrl+C לביטול)
pause >nul

echo.
echo ► שלב 1: בודק מצב שרת...
echo ══════════════════════════
call CHECK-SERVER-STATUS.bat

echo.
echo ► שלב 2: מתקן URLs מקומיים...
echo ═════════════════════════════
call FIX-ALL-URLS-LOCAL.bat

echo.
echo ► שלב 3: מעלה ובונה באתר חדש...
echo ═════════════════════════════════
call CREATE-NEW-SITE3.bat

echo.
echo ════════════════════════════════════════════════════
echo              ✨ הכל מוכן! ✨
echo ════════════════════════════════════════════════════
echo.
echo 🌐 האתר החדש שלך:
echo    http://31.97.129.5:5173
echo.
echo 🔑 כניסה למערכת:
echo    שם משתמש: admin
echo    סיסמה: 123456
echo.
echo 📝 מה יש במערכת:
echo    ✓ תיקיית "בהמתנה לתשובה"
echo    ✓ כפתור "צור טיוטה"
echo    ✓ ניהול טיוטות מלא
echo.
echo ════════════════════════════════════════════════════
echo.
echo לחץ Enter לפתוח בדפדפן...
pause >nul
start http://31.97.129.5:5173