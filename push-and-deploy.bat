@echo off
echo ===== Push & Deploy עם GitHub Action =====
echo.

echo [1] מוסיף את כל הקבצים...
git add .

echo.
echo [2] יוצר commit...
git commit -m "Auto deploy via GitHub Action - %date% %time%"

echo.
echo [3] דוחף ל-GitHub (זה יפעיל את הפריסה האוטומטית)...
git push origin main

echo.
echo ===== הושלם! =====
echo.
echo 🚀 GitHub Action התחיל לרוץ!
echo.
echo 📊 ראה את ההתקדמות ב:
echo https://github.com/shalomfr/smartsmart/actions
echo.
echo ⏱️  הפריסה תיקח כ-2-3 דקות
echo.
echo 🌐 האתר יתעדכן אוטומטית ב:
echo http://31.97.129.5
echo.
pause