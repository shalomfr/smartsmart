@echo off
chcp 65001 >nul
cls
color 0F
echo ===============================================
echo        📋 צפייה בלוגים בזמן אמת 📋
echo ===============================================
echo.
echo 🔄 מתחבר ללוגי השרת...
echo 🛑 לעצירה: Ctrl+C
echo.
echo ================================================
echo.

ssh root@31.97.129.5 "pm2 logs email-backend --follow"