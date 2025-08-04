@echo off
echo =============================================
echo   📧 מעלה שיפורים לתשובה חכמה
echo =============================================
echo.

cd /d "C:\mail\0548481658"

echo מוסיף שינויים...
git add -A

echo יוצר commit...
git commit -m "Improve smart reply - inline panel and full email context"

echo מעלה לגיטהאב...
git push origin main

echo.
echo מעדכן את השרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm run build && cd backend && npm install && pm2 restart all"

echo.
echo =============================================
echo ✅ הכל מוכן!
echo =============================================
echo.
echo השיפורים:
echo 1. פאנל תשובה נפתח מתחת למייל
echo 2. AI קורא את כל תוכן המייל
echo 3. אפשר לערוך את התשובה
echo 4. הכל בעברית ועם אנימציות
echo.
pause