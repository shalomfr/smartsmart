@echo off
chcp 65001 >nul
cls
echo ****************************************************
echo *           בדיקת מערכת הבנייה                   *
echo ****************************************************
echo.

echo [1] בודק איזה build system בשימוש...
echo =====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && ls -la vite.config.* webpack.config.* 2>/dev/null"

echo.
echo [2] בודק את package.json...
echo ===========================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && grep -E 'scripts|vite|webpack|react-scripts' package.json | head -20"

echo.
echo [3] בודק את AuthContext הנוכחי בשרת...
echo =======================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/contexts && grep -n 'API_URL' AuthContext.jsx | head -5"

echo.
echo [4] מה כתוב בקבצים הבנויים...
echo ===============================
ssh root@31.97.129.5 "cd /home/emailapp/site2/dist/assets && grep -h 'localhost:3001\\|localhost:4000\\|/api' *.js | grep -v '^//' | head -5"

echo.
pause