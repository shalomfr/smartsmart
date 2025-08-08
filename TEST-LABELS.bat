@echo off
echo ================================================
echo   בדיקת תוויות במיילים
echo ================================================
echo.

echo [1] בודק קוד התוויות בשרת...
echo ================================
ssh root@31.97.129.5 "echo 'Main site:' && grep -A 20 'שלוף תוויות Gmail' /home/emailapp/email-app/backend/server.js | head -25"

echo.
echo [2] בודק לוגים של תוויות...
echo ================================
ssh root@31.97.129.5 "pm2 logs backend --lines 50 | grep -i label || echo 'No label logs found'"

echo.
echo [3] מציג דוגמאות לתרגומים:
echo ================================
echo תוויות Gmail מקוריות -> תרגום לעברית:
echo.
echo Important -> חשוב
echo IMPORTANT -> חשוב
echo CATEGORY_SOCIAL -> רשתות חברתיות
echo CATEGORY_PROMOTIONS -> מבצעים
echo CATEGORY_UPDATES -> עדכונים
echo CATEGORY_PRIMARY -> ראשי
echo.
echo תוויות שיוסרו:
echo -BdEF2QXq& -> יוסר (מכיל & ומתחיל ב-)
echo -BdAF3AXj& -> יוסר (מכיל & ומתחיל ב-)
echo תוויות ארוכות מ-15 תווים -> יוסרו
echo.
pause