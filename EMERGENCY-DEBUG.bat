@echo off
chcp 65001 >nul
cls
echo ****************************************************
echo *            דיבוג חירום - מה הבעיה?             *
echo ****************************************************
echo.

echo 1. בדיקת קבצים מקומיים:
echo =========================
echo Layout.jsx:
type src\pages\Layout.jsx | find /n "בהמתנה לתשובה" | head -1
echo.
echo Inbox.jsx:
type src\pages\Inbox.jsx | find /n "צור טיוטה" | head -1

echo.
echo 2. בדיקת קבצים בשרת:
echo ======================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'Layout בשרת:' && grep -n 'בהמתנה לתשובה' Layout.jsx | head -1"
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/pages && echo 'Inbox בשרת:' && grep -n 'צור טיוטה' Inbox.jsx | head -1"

echo.
echo 3. בדיקת בנייה:
echo ===============
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && echo 'בקבצים הבנויים:' && grep -l 'בהמתנה לתשובה' *.js 2>/dev/null | wc -l"

echo.
echo 4. פורטים פתוחים:
echo ==================
ssh root@31.97.129.5 "netstat -tlnp | grep :80"

echo.
echo ****************************************************
echo *                   אבחון                         *
echo ****************************************************
echo.
echo אם "בדיקת קבצים מקומיים" = יש
echo ואם "בדיקת קבצים בשרת" = אין
echo אז: הבעיה בהעלאה
echo.
echo אם "בדיקת קבצים בשרת" = יש  
echo ואם "בקבצים הבנויים" = 0
echo אז: הבעיה בבנייה
echo.
echo אם אתה נכנס ל-:8080 במקום :8081
echo אז: אתה באתר הלא נכון!
echo.
echo ****************************************************
echo.
pause