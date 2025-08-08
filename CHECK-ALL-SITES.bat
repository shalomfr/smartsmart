@echo off
echo ================================================
echo      בדיקת סטטוס כל האתרים
echo ================================================
echo.

echo מתחבר לשרת...
echo.

ssh root@31.97.129.5 "bash -c '
echo \"=== PM2 Apps ===\"
pm2 list

echo
echo \"=== Nginx Sites ===\"
for site in /etc/nginx/sites-enabled/*; do
    if [ -f \"\$site\" ]; then
        echo -n \"Site: \$(basename \$site) - \"
        if nginx -t -c /etc/nginx/nginx.conf -g \"include \$site;\" 2>/dev/null; then
            echo \"OK\"
        else
            echo \"ERROR\"
        fi
    fi
done

echo
echo \"=== Open Ports ===\"
netstat -tlnp | grep -E \":(80|443|3001|3002|3003|8080|8081|8082)\" | awk \"{print \\\"Port \\\" \\\$4 \\\" - \\\" \\\$7}\"

echo
echo \"=== Disk Usage ===\"
df -h | grep -E \"^/dev/\"

echo
echo \"=== Memory Usage ===\"
free -h | grep -E \"^Mem:\"

echo
echo \"=== Test URLs ===\"
echo \"- Main site: http://31.97.129.5\"
curl -s -o /dev/null -w \"  Status: %%{http_code}\\n\" http://localhost

# בדוק אתרים נוספים אם קיימים
for port in 8081 8082 8083; do
    if netstat -tlnp | grep -q \":\$port\"; then
        echo \"- Site on port \$port: http://31.97.129.5:\$port\"
        curl -s -o /dev/null -w \"  Status: %%{http_code}\\n\" http://localhost:\$port
    fi
done
'"

echo.
echo ================================================
echo      סיום בדיקה
echo ================================================
echo.
pause