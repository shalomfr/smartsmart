@echo off
echo ========================================
echo   פקודות פשוטות לתיקון השרת
echo ========================================
echo.
echo העתק כל פקודה והרץ בטרמינל:
echo.
echo 1. התחבר לשרת:
echo    ssh root@31.97.129.5
echo.
echo 2. אחרי החיבור, הרץ:
echo    cd /home/emailapp
echo    rm -rf email-app
echo    git clone https://github.com/shalomfr/smartsmart.git email-app
echo    cd email-app
echo    npm install
echo    npm run build
echo    cd backend
echo    npm install
echo    pm2 restart all
echo.
pause