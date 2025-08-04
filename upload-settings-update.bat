@echo off
echo =============================================
echo   מעלה עדכון הגדרות מוצפנות לגיט
echo =============================================
echo.

REM עובר לתיקייה הנכונה
cd /d "C:\mail\0548481658"

REM בודק סטטוס
echo בודק סטטוס Git...
git status
echo.

REM מוסיף שינויים
echo מוסיף את כל השינויים...
git add -A
echo.

REM יוצר commit
echo יוצר commit...
git commit -m "Add encrypted server settings - save and load credentials securely"
echo.

REM מעלה לגיטהאב
echo מעלה לגיטהאב...
git push origin main
echo.

REM בודק אם הצליח
if %ERRORLEVEL% == 0 (
    echo =============================================
    echo ✅ הועלה בהצלחה!
    echo =============================================
    echo.
    echo כעת מעדכן את השרת...
    echo.
    
    REM מעדכן את השרת
    ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && cd backend && npm install && pm2 restart email-app-backend"
    
    echo.
    echo ✅ השרת עודכן!
) else (
    echo =============================================
    echo ❌ משהו השתבש...
    echo =============================================
    echo.
    echo נסה את הפקודות הבאות ידנית:
    echo 1. git add -A
    echo 2. git commit -m "Add encrypted server settings"
    echo 3. git push origin main
    echo.
    echo אם יש שגיאה, שלח לי אותה.
)

echo.
pause