@echo off
echo =============================================
echo   מעלה תיקון לתשובה חכמה
echo =============================================
echo.

cd /d "C:\mail\0548481658"

echo מוסיף שינויים...
git add -A

echo יוצר commit...
git commit -m "Fix smart reply - auto-fill recipient and subject fields"

echo מעלה לגיטהאב...
git push origin main

echo.
echo מעדכן את השרת...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && npm run build && pm2 restart email-app-frontend"

echo.
echo ✅ הכל מוכן!
echo.
echo השינויים:
echo - שדה הנמען מתמלא אוטומטית
echo - שדה הנושא מתמלא עם Re:
echo - הודעות בעברית
echo.
pause