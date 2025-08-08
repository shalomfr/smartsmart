@echo off
echo ================================================
echo   הצג תוויות גולמיות - בלי תרגום
echo ================================================
echo.

echo מחליף זמנית את הקוד להציג הכל...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cat > show-raw.js << 'EOF'
const fs = require('fs');
let content = fs.readFileSync('server.js', 'utf8');

// מצא את קטע התוויות
const start = content.indexOf('// שלוף תוויות Gmail');
const end = content.indexOf('attributesSet = true;', start) + 'attributesSet = true;'.length;

if (start > -1) {
    const simpleCode = `// שלוף תוויות Gmail - DEBUG MODE
            if (attrs['x-gm-labels']) {
              console.log('=== RAW GMAIL LABELS ===');
              console.log(JSON.stringify(attrs['x-gm-labels']));
              console.log('=======================');
              
              // פשוט הצג את כל התוויות כמו שהן
              email.labels = attrs['x-gm-labels'].map(label => {
                return String(label).replace(/\\\\\\\\$/, '').replace(/\\\\$/, '');
              });
            } else {
              email.labels = ['No Gmail Labels'];
            }
            
            attributesSet = true;`;
    
    content = content.substring(0, start) + simpleCode + content.substring(end);
    fs.writeFileSync('server.js', content);
    console.log('Set to raw labels mode!');
}
EOF

node show-raw.js && rm show-raw.js && pm2 restart site2-backend"

echo.
echo ================================================
echo   עכשיו תראה את כל התוויות כמו שהן!
echo ================================================
echo.
echo 1. פתח את האתר
echo 2. טען מיילים
echo 3. תראה את כל התוויות הגולמיות
echo 4. לחץ Enter כדי לראות לוגים
echo.
pause

echo.
echo === תוויות גולמיות מהלוגים ===
ssh root@31.97.129.5 "pm2 logs site2-backend --lines 50 | grep -A2 'RAW GMAIL LABELS'"

echo.
echo ================================================
echo   אחרי שתראה מה יש, הרץ:
echo   FIX-ALL-LABELS.bat
echo ================================================
echo.
pause