@echo off
chcp 65001 >nul
cls
color 0B
echo ****************************************************
echo *       בדיקת לוגיקת כניסה ב-Frontend            *
echo ****************************************************
echo.

echo [1] מחפש את קוד הכניסה ב-Frontend...
echo =====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && grep -h 'login\\|username\\|password' *.js | grep -v 'http://' | head -10"

echo.
echo [2] בודק מה השדות בטופס...
echo ============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src && grep -r 'שם משתמש\\|username' . 2>/dev/null | head -5"

echo.
echo [3] בודק אם יש הגדרות ברירת מחדל...
echo ===================================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && grep -r 'defaultUser\\|testUser\\|admin.*password' . 2>/dev/null | grep -v node_modules | head -10"

echo.
echo [4] בודק קבצי env לדוגמה...
echo ===========================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && cat .env.example 2>/dev/null || cat .env.sample 2>/dev/null || echo 'אין קובץ דוגמה'"

echo.
echo ****************************************************
echo          💡 רגע של אמת
echo ****************************************************
echo.
echo אם זו מערכת פשוטה (לא מייל), נסה:
echo.
echo   שם משתמש: admin
echo   סיסמה: admin
echo.
echo או בדוק אם יש קובץ הוראות התקנה
echo.
pause