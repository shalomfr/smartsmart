@echo off
chcp 65001 >nul
cls
echo ================================================
echo      איך לוודא שהשינויים נטענו
echo ================================================
echo.
echo 1. פתח את האתר: http://31.97.129.5:8081
echo.
echo 2. לחץ F12 (כלי פיתוח)
echo.
echo 3. עבור לכרטיסיית "Console"
echo.
echo 4. הקלד ורץ את הפקודות הבאות:
echo.
echo    // בדיקת תיקייה בתפריט
echo    document.body.textContent.includes('בהמתנה לתשובה')
echo.
echo    // בדיקת כפתור טיוטה
echo    document.body.textContent.includes('צור טיוטה')
echo.
echo 5. אם מחזיר false:
echo    - סגור את הדפדפן לגמרי
echo    - פתח מחדש בחלון גלישה בסתר
echo.
echo 6. אם עדיין false:
echo    - רענן עם Ctrl+Shift+R
echo    - או נקה את כל נתוני הגלישה
echo.
echo ================================================
echo.
echo טיפ: תמיד השתמש בגלישה בסתר לבדיקות!
echo.
pause