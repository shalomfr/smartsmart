@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *          בדיקת כניסה ישירה                     *
echo ****************************************************
echo.

echo [1] בודק אם ה-Backend עובד...
echo =============================
ssh root@31.97.129.5 "curl -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}' 2>/dev/null"

echo.
echo.
echo [2] בודק מהמחשב שלך (לא מהשרת)...
echo ===================================
echo מנסה להתחבר ל-Backend ישירות:
curl -X POST http://31.97.129.5:4000/api/app/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"123456\"}" 2>nul

echo.
echo.
echo ****************************************************
echo *               מה זה אומר?                      *
echo ****************************************************
echo.
echo אם ראית "success: true" - ה-Backend עובד!
echo הבעיה היא בחיבור בין Frontend ל-Backend.
echo.
echo אם ראית שגיאה - ה-Backend לא עובד כמו שצריך.
echo.
echo ****************************************************
echo.
pause