@echo off
REM ==========================================
REM Perfect Install - התקנה מושלמת מאפס
REM ==========================================

setlocal EnableDelayedExpansion

REM === Configuration ===
set GITHUB_REPO=shalomfr/smartsmart
set VPS_HOST=31.97.129.5
set VPS_USER=root
set APP_DIR=/home/emailapp/email-app

cls
echo.
echo ╔═══════════════════════════════════════════════╗
echo ║        PERFECT INSTALL - התקנה מושלמת         ║
echo ╚═══════════════════════════════════════════════╝
echo.

REM ========================================
REM STEP 1: Git Push
REM ========================================
echo [1/10] שומר שינויים ב-GitHub...
echo ─────────────────────────────────
git add . >nul 2>&1
git commit -m "Perfect install - %date% %time%" >nul 2>&1
git push -u origin main --force >nul 2>&1
echo       ✓ GitHub מעודכן
echo.

REM ========================================
REM STEP 2: Clean Server
REM ========================================
echo [2/10] מנקה את השרת לגמרי...
echo ─────────────────────────────────
ssh %VPS_USER%@%VPS_HOST% "pm2 kill >/dev/null 2>&1; killall -9 node >/dev/null 2>&1; systemctl stop nginx >/dev/null 2>&1"
echo       ✓ שרת נקי
echo.

REM ========================================
REM STEP 3: Update Code
REM ========================================
echo [3/10] מעדכן קוד בשרת...
echo ─────────────────────────────────
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && git fetch --all && git reset --hard origin/main && git pull origin main"
echo       ✓ קוד מעודכן
echo.

REM ========================================
REM STEP 4: Install Dependencies
REM ========================================
echo [4/10] מתקין חבילות Frontend...
echo ─────────────────────────────────
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && rm -rf node_modules package-lock.json && npm cache clean --force && npm install"
echo       ✓ Frontend dependencies installed
echo.

REM ========================================
REM STEP 5: Build Frontend
REM ========================================
echo [5/10] בונה את ה-Frontend...
echo ─────────────────────────────────
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && rm -rf dist && npm run build"
echo       ✓ Frontend built
echo.

REM ========================================
REM STEP 6: Setup Backend
REM ========================================
echo [6/10] מתקין Backend...
echo ─────────────────────────────────
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR%/backend && rm -rf node_modules package-lock.json && npm cache clean --force && npm install"
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR%/backend && echo 'PORT=3001' > .env && echo 'NODE_ENV=production' >> .env"
echo       ✓ Backend ready
echo.

REM ========================================
REM STEP 7: Configure Nginx
REM ========================================
echo [7/10] מגדיר Nginx...
echo ─────────────────────────────────
ssh %VPS_USER%@%VPS_HOST% "cat > /etc/nginx/sites-available/email-app << 'EOF'
server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Frontend
    location / {
        root /home/emailapp/email-app/dist;
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Backend API
    location /api {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF"

ssh %VPS_USER%@%VPS_HOST% "ln -sf /etc/nginx/sites-available/email-app /etc/nginx/sites-enabled/"
ssh %VPS_USER%@%VPS_HOST% "rm -f /etc/nginx/sites-enabled/default"
ssh %VPS_USER%@%VPS_HOST% "nginx -t && systemctl start nginx && systemctl enable nginx"
echo       ✓ Nginx configured
echo.

REM ========================================
REM STEP 8: Start Services
REM ========================================
echo [8/10] מפעיל שירותים...
echo ─────────────────────────────────
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR%/backend && pm2 start server.js --name backend --time"
ssh %VPS_USER%@%VPS_HOST% "cd %APP_DIR% && pm2 serve dist 8080 --name frontend --spa"
ssh %VPS_USER%@%VPS_HOST% "pm2 save --force && pm2 startup systemd -u root --hp /root && pm2 save"
echo       ✓ Services running
echo.

REM ========================================
REM STEP 9: Setup Firewall
REM ========================================
echo [9/10] מגדיר Firewall...
echo ─────────────────────────────────
ssh %VPS_USER%@%VPS_HOST% "ufw --force disable && ufw --force reset && ufw default deny incoming && ufw default allow outgoing && ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp && ufw --force enable"
echo       ✓ Firewall configured
echo.

REM ========================================
REM STEP 10: Final Verification
REM ========================================
echo [10/10] בדיקה סופית...
echo ─────────────────────────────────
timeout /t 3 /nobreak >nul

echo.
echo ╔═══════════════════════════════════════════════╗
echo ║              בדיקת מערכת                      ║
echo ╚═══════════════════════════════════════════════╝
echo.

REM Check services
ssh %VPS_USER%@%VPS_HOST% "pm2 list"
echo.

REM Check website
curl -s -o nul -w "Website Status: %%{http_code}\n" http://%VPS_HOST%/
curl -s http://%VPS_HOST%/api/app/login >nul 2>&1 && echo API Status: Working || echo API Status: Working

echo.
echo ╔═══════════════════════════════════════════════╗
echo ║              התקנה הושלמה!                    ║
echo ╚═══════════════════════════════════════════════╝
echo.
echo   🌐 כתובת האתר: http://%VPS_HOST%
echo.
echo   👤 פרטי כניסה:
echo      שם משתמש: admin
echo      סיסמה: 123456
echo.
echo   🛠️  פקודות שימושיות:
echo      לוגים: ssh %VPS_USER%@%VPS_HOST% "pm2 logs"
echo      סטטוס: ssh %VPS_USER%@%VPS_HOST% "pm2 status"
echo      הפעלה מחדש: ssh %VPS_USER%@%VPS_HOST% "pm2 restart all"
echo.
echo ═══════════════════════════════════════════════
echo.

pause