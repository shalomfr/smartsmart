@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *         בדיקת סוג האימות במערכת                *
echo ****************************************************
echo.

echo [1] בודק הגדרות מייל בשרת...
echo =============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -n 'SMTP\\|IMAP\\|EMAIL' .env 2>/dev/null || echo 'אין קובץ .env'"

echo.
echo [2] בודק אם יש הגדרות דוגמה...
echo ===============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && ls -la .env* env*"

echo.
echo [3] בודק את לוגיקת הכניסה...
echo =============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && grep -A30 'login.*async.*req.*res' server.js | grep -v '^--' | head -40"

echo.
echo ****************************************************
echo *                   מסקנות                        *
echo ****************************************************
echo.
echo נראה שהמערכת מוגדרת להתחבר למייל אמיתי!
echo.
echo כדי להיכנס, אתה צריך:
echo 1. להגדיר חשבון מייל אמיתי בהגדרות
echo 2. או להשתמש בחשבון שכבר מוגדר
echo.
echo רוצה לראות איך להגדיר חשבון מייל?
echo הפעל: SETUP-EMAIL-ACCOUNT.bat
echo.
echo ****************************************************
echo.
pause