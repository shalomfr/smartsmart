@echo off
chcp 65001 >nul
cls
echo ================================================
echo     בדיקת מצב נוכחי של השרת (31.97.129.5)
echo ================================================
echo.

set SERVER=31.97.129.5
set USER=root

echo [1] PM2 Apps (מסונן)...
ssh %USER%@%SERVER% "pm2 list | egrep -i 'email|site|backend|frontend|Name'" || echo (שגיאה ב-PM2)
echo.

echo [2] פתיחת פורטים...
ssh %USER%@%SERVER% "netstat -tlnp 2>/dev/null | egrep ':80|:443|:3001|:4000|:8080|:8081|:8082|:9000' || ss -ltnp 2>/dev/null | egrep ':80|:443|:3001|:4000|:8080|:8081|:8082|:9000'" || echo (שגיאה ב-netstat/ss)
echo.

echo [3] תיקיות קיימות ב-/home/emailapp ...
ssh %USER%@%SERVER% "ls -la /home/emailapp | egrep 'email-app|email-prod|site2|site3|site4' || true"
echo.

echo [4] בדיקת קבצי אתר (dist) אם קיימים...
ssh %USER%@%SERVER% "bash -lc 'for d in /home/emailapp/email-app /home/emailapp/email-prod /home/emailapp/site2 /home/emailapp/site3; do if [ -d \"$d/dist\" ]; then echo \"Found dist in: $d\"; ls -la $d/dist | head -5; fi; done'"
echo.

echo [5] בדיקת HTTP מקומית על השרת...
ssh %USER%@%SERVER% "bash -lc 'for url in http://localhost http://localhost:8080 http://localhost:8081 http://localhost:9000; do which curl >/dev/null 2>&1 && curl -s -o /dev/null -w "URL: $url -> HTTP %{http_code}\n" $url || echo "curl not installed"; done'"
echo.

echo [6] בדיקת API Login (app/login) על 3001 ו-4000...
ssh %USER%@%SERVER% "bash -lc 'for p in 3001 4000; do if which curl >/dev/null 2>&1; then echo -n "POST /api/app/login on :$p -> "; curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST http://localhost:$p/api/app/login -H "Content-Type: application/json" -d '{\"username\":\"admin\",\"password\":\"123456\"}'; fi; done'"
echo.

echo ================================================
echo  סיום בדיקה. עיין בפלט כדי לבחור יעד פריסה (email-app/site2)
echo ================================================


