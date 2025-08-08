@echo off
chcp 65001 >nul
echo ================================================
echo      מערכת פענוח תוויות עבריות - הסבר
echo ================================================
echo.
echo המערכת תומכת ב-3 שיטות לתוויות בעברית:
echo.
echo 1. פענוח אוטומטי מ-Modified UTF-7:
echo    &BdEF2QXq- → משפחה (אוטומטי!)
echo    &BdAF3AXj- → עבודה (אוטומטי!)
echo    כל תווית מקודדת → תפוענח אוטומטית!
echo.
echo 2. תרגום תוויות באנגלית:
echo    Important → חשוב
echo    Sent → נשלח
echo    Starred → מסומן בכוכב
echo.
echo 3. תוויות שכבר בעברית:
echo    משפחה → משפחה (נשאר כמו שהוא)
echo    עבודה → עבודה (נשאר כמו שהוא)
echo.
echo ================================================
echo.
echo כדי להתקין ולבדוק:
echo   QUICK-INSTALL-AND-TEST.bat
echo.
echo לבדיקה מהירה:
echo   TEST-AUTO-DECODE.bat
echo.
pause