@echo off
REM ==========================================
REM Rebuild Website - בניית האתר מחדש
REM ==========================================

cls
echo.
echo ╔═══════════════════════════════════════════════╗
echo ║         בונה את האתר מחדש מאפס                ║
echo ╚═══════════════════════════════════════════════╝
echo.

REM ============================
REM Step 1: Push to GitHub
REM ============================
echo [1/7] שומר שינויים ב-GitHub...
git add . >nul 2>&1
git commit -m "Rebuild website %date% %time%" >nul 2>&1
git push -u origin main --force >nul 2>&1
echo       ✓ GitHub מעודכן
echo.

REM ============================
REM Step 2: Clean old build
REM ============================
echo [2/7] מנקה build ישן...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && rm -rf dist node_modules package-lock.json"
echo       ✓ ניקוי הושלם
echo.

REM ============================
REM Step 3: Pull latest code
REM ============================
echo [3/7] מושך קוד עדכני...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && git fetch --all && git reset --hard origin/main"
echo       ✓ קוד עדכני
echo.

REM ============================
REM Step 4: Install dependencies
REM ============================
echo [4/7] מתקין חבילות (זה ייקח דקה)...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && npm cache clean --force && npm install --legacy-peer-deps"
echo       ✓ חבילות הותקנו
echo.

REM ============================
REM Step 5: Build website
REM ============================
echo [5/7] בונה את האתר...
ssh root@31.97.129.5 "cd /home/emailapp/email-app && npm run build"
echo       ✓ האתר נבנה
echo.

REM ============================
REM Step 6: Fix Nginx
REM ============================
echo [6/7] מתקן את Nginx...
ssh root@31.97.129.5 "cat > /etc/nginx/sites-available/email-app << 'NGINX_END'
server {
    listen 80;
    server_name _;
    
    location / {
        root /home/emailapp/email-app/dist;
        try_files \$uri \$uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
NGINX_END"

ssh root@31.97.129.5 "nginx -t && systemctl restart nginx"
echo       ✓ Nginx מוגדר
echo.

REM ============================
REM Step 7: Restart services
REM ============================
echo [7/7] מפעיל מחדש שירותים...
ssh root@31.97.129.5 "pm2 restart all || (cd /home/emailapp/email-app/backend && pm2 start server.js --name backend && cd .. && pm2 serve dist 8080 --name frontend --spa && pm2 save)"
echo       ✓ שירותים פועלים
echo.

REM ============================
REM Final check
REM ============================
echo ╔═══════════════════════════════════════════════╗
echo ║              בדיקה סופית                      ║
echo ╚═══════════════════════════════════════════════╝
echo.

ssh root@31.97.129.5 "echo '=== שירותים ===' && pm2 list && echo && echo '=== פורטים ===' && netstat -tlnp | grep -E ':80|:3001|:8080' | grep LISTEN"

echo.
timeout /t 3 /nobreak >nul
echo בודק אתר...
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://31.97.129.5/

echo.
echo ╔═══════════════════════════════════════════════╗
echo ║              הבנייה הושלמה!                   ║
echo ╚═══════════════════════════════════════════════╝
echo.
echo   🌐 האתר: http://31.97.129.5
echo.
echo   👤 כניסה:
echo      משתמש: admin (באותיות קטנות!)
echo      סיסמה: 123456
echo.
echo ═══════════════════════════════════════════════
echo.
pause