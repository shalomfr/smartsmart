@echo off
echo ================================================
echo      בדיקת site2
echo ================================================
echo.

echo בודק אם site2 פועל...
echo.

ssh root@31.97.129.5 "bash -c '
echo \"=== PM2 Status for site2 ===\"
pm2 list | grep site2

echo
echo \"=== Port Status ===\"
echo -n \"Port 4000 (Backend): \"
netstat -tlnp | grep :4000 > /dev/null && echo \"OPEN\" || echo \"CLOSED\"
echo -n \"Port 9000 (Frontend): \"
netstat -tlnp | grep :9000 > /dev/null && echo \"OPEN\" || echo \"CLOSED\"
echo -n \"Port 8081 (Nginx): \"
netstat -tlnp | grep :8081 > /dev/null && echo \"OPEN\" || echo \"CLOSED\"

echo
echo \"=== Testing URLs ===\"
echo -n \"Main site (http://31.97.129.5:8081): \"
curl -s -o /dev/null -w \"%%{http_code}\\n\" http://localhost:8081

echo -n \"Backend API (http://31.97.129.5:4000/api): \"
curl -s -o /dev/null -w \"%%{http_code}\\n\" http://localhost:4000/api

echo -n \"Frontend (http://31.97.129.5:9000): \"
curl -s -o /dev/null -w \"%%{http_code}\\n\" http://localhost:9000

echo
echo \"=== Logs (last 5 lines) ===\"
echo \"Backend logs:\"
pm2 logs site2-backend --lines 5 --nostream 2>/dev/null || echo \"No logs available\"

echo
echo \"=== File Check ===\"
echo -n \"Site directory exists: \"
[ -d /home/emailapp/site2 ] && echo \"YES\" || echo \"NO\"
echo -n \"Build exists: \"
[ -f /home/emailapp/site2/dist/index.html ] && echo \"YES\" || echo \"NO\"
'"

echo.
echo ================================================
echo      סיכום
echo ================================================
echo.
echo אם כל הבדיקות מראות:
echo - PM2: online
echo - Ports: OPEN
echo - HTTP Status: 200
echo.
echo אז האתר עובד! גש ל:
echo http://31.97.129.5:8081
echo.
pause