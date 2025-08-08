@echo off
chcp 65001 >nul
echo ================================================
echo    בדיקת Frontend ישירות מהשרת
echo ================================================
echo.

echo בודק את קובץ ה-JavaScript הסופי...
echo.

ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && echo 'חיפוש בקבצי JS:' && grep -l 'בהמתנה לתשובה' *.js 2>/dev/null | head -5"

echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && echo 'חיפוש צור טיוטה:' && grep -l 'צור טיוטה' *.js 2>/dev/null | head -5"

echo.
echo בודק תאריך בנייה אחרון...
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist && ls -la index.html"

echo.
echo מתי נבנה לאחרונה...
echo.
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && ls -lt *.js | head -5"

echo.
echo ================================================
echo אם אתה רואה תאריכים ישנים:
echo הפעל: npm run build
echo.
echo אם אתה לא רואה את הטקסטים:
echo הבנייה לא עדכנה את הקבצים
echo ================================================
pause