@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *         פתרון פשוט עם Proxy                    *
echo ****************************************************
echo.

echo [1] מעדכן vite.config.js עם proxy...
echo ====================================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && cp vite.config.js vite.config.js.backup"

ssh root@31.97.129.5 "cd /home/emailapp/site2 && cat > vite-proxy.txt << 'EOF'
export default {
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true
      }
    }
  }
}
EOF"

ssh root@31.97.129.5 "cd /home/emailapp/site2 && sed -i '/export default/,/^}/c\export default {\n  server: {\n    proxy: {\n      \"/api\": {\n        target: \"http://localhost:4000\",\n        changeOrigin: true\n      }\n    }\n  }\n}' vite.config.js"

echo.
echo [2] מעדכן AuthContext לשימוש ב-/api בלבד...
echo ============================================
ssh root@31.97.129.5 "cd /home/emailapp/site2/src/contexts && sed -i \"s|const API_URL = .*|const API_URL = '/api';|\" AuthContext.jsx"

echo.
echo [3] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [4] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart site2-frontend site2-backend"

echo.
echo ****************************************************
echo *           סיימנו! נסה עכשיו                     *
echo ****************************************************
echo.
echo כתובת: http://31.97.129.5:8082
echo.
echo שם משתמש: admin
echo סיסמה: 123456
echo.
pause