@echo off
echo ================================================
echo   בדיקת תוויות Gmail
echo ================================================
echo.

echo [1] בודק איך Gmail שולח תוויות...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cat > check-gmail-labels.js << 'EOF'
// הוסף לוג מפורט לראות מה Gmail שולח
const fs = require('fs');
let content = fs.readFileSync('server.js', 'utf8');

// הוסף לוגים מפורטים
content = content.replace(
  \"msg.once('attributes', (attrs) => {\",
  `msg.once('attributes', (attrs) => {
    console.log('=== FULL ATTRIBUTES ===');
    console.log('All flags:', attrs.flags);
    console.log('Gmail labels:', attrs['x-gm-labels']);
    console.log('Gmail thrid:', attrs['x-gm-thrid']);
    console.log('Gmail msgid:', attrs['x-gm-msgid']);
    console.log('===================');`
);

fs.writeFileSync('server.js', content);
console.log('Added detailed logging');
EOF

node check-gmail-labels.js && rm check-gmail-labels.js && pm2 restart site2-backend"

echo.
echo ================================================
echo   עכשיו פתח מייל באתר
echo ================================================
echo.
echo אחרי שתפתח מייל, לחץ Enter
pause

echo.
echo === לוגים מ-Gmail ===
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 100 | grep -A10 'FULL ATTRIBUTES'"

echo.
pause