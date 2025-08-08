@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *           תיקון חיבור API                       *
echo ****************************************************
echo.

echo [1] בודק על איזה פורט ה-Frontend רץ...
echo ======================================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8082|4000)'"

echo.
echo [2] בודק הגדרות proxy ב-package.json...
echo ========================================
type package.json | findstr /n "proxy"

echo.
echo [3] מוסיף proxy להפניה נכונה...
echo =================================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && grep -n 'proxy' package.json || echo '{}' | jq '. + {\"proxy\": \"http://localhost:4000\"}' > temp.json && mv temp.json package.json"

echo.
echo [4] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [5] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart site2-frontend site2-backend"

echo.
echo ****************************************************
echo *               פרטי כניסה                        *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8082
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
echo או:
echo.
echo שם משתמש: user1
echo סיסמה: password
echo.
echo ****************************************************
echo.
pause