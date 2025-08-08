@echo off
chcp 65001 >nul
cls
color 0C
echo ================================================
echo    📋 צפייה בלוגי מערכת תשובה אוטומטית 📋
echo ================================================
echo.
echo 🔄 מתחבר ללוגי השרת...
echo 🛑 לעצירה: Ctrl+C
echo.
echo תראה כאן:
echo ✅ התחברות משתמשים
echo ✅ הפעלת/כיבוי אוטו-ריפליי  
echo ✅ בדיקות מיילים חדשים
echo ✅ יצירת תשובות
echo ❌ שגיאות
echo.
echo ================================================
echo.

ssh root@31.97.129.5 "pm2 logs email-backend --lines 0 | grep -E 'AUTO-REPLY|LOGIN|ERROR'"