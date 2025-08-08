@echo off
echo ================================================
echo   בדיקת תוויות בזמן אמת
echo ================================================
echo.

echo מוסיף לוגים זמניים לראות מה קורה...
echo.

ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cat > add-debug-logs.js << 'EOF'
const fs = require('fs');
let content = fs.readFileSync('server.js', 'utf8');

// הוסף לוג בתחילת פונקציית fetch
content = content.replace(
  \"fetch.on('message', (msg, seqno) => {\",
  \"fetch.on('message', (msg, seqno) => {\\n        console.log('=== Processing email', seqno, '===');\"
);

// הוסף לוג לתוויות
if (!content.includes('console.log(\\'Raw labels')) {
  content = content.replace(
    \"if (attrs['x-gm-labels']) {\",
    \"if (attrs['x-gm-labels']) {\\n              console.log('Raw labels from Gmail:', JSON.stringify(attrs['x-gm-labels']));\"
  );
}

fs.writeFileSync('server.js', content);
console.log('Debug logs added!');
EOF

node add-debug-logs.js && rm add-debug-logs.js && pm2 restart site2-backend"

echo.
echo ================================================
echo   עכשיו פתח את האתר וטען מיילים
echo ================================================
echo.
echo אחרי שתפתח מייל, לחץ Enter כדי לראות לוגים
pause

echo.
echo === לוגים אחרונים ===
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 50 | grep -E 'Raw labels|Processing email' | tail -20"

echo.
echo ================================================
echo   מה לחפש בלוגים:
echo ================================================
echo.
echo אם רואים:
echo   Raw labels from Gmail: ["Important\\"]
echo.
echo אז הבעיה היא הסלאש בסוף.
echo פתרון: הרץ את REPLACE-LABELS-CODE.bat
echo.
pause