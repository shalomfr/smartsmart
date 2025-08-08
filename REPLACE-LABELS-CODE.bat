@echo off
echo ================================================
echo   החלפת קוד התוויות - פתרון מלא
echo ================================================
echo.

echo מחליף את כל קוד התוויות ב-site2...
echo.

ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cat > replace-labels.js << 'ENDSCRIPT'
const fs = require('fs');
let content = fs.readFileSync('server.js', 'utf8');

// מצא את כל החלק של התוויות
const startPattern = /\/\/ שלוף תוויות Gmail[\s\S]*?attributesSet = true;/;
const match = content.match(startPattern);

if (match) {
    const newLabelsCode = `// שלוף תוויות Gmail
            if (attrs['x-gm-labels']) {
              email.labels = [];
              
              for (let label of attrs['x-gm-labels']) {
                // נקה את התווית
                label = String(label).trim().replace(/\\\\\\\\$/, '');
                
                // דלג על תוויות עם קודים
                if (label.includes('&') || label.startsWith('-')) continue;
                
                // תרגומים
                const lowerLabel = label.toLowerCase();
                if (lowerLabel === 'important' || lowerLabel === 'important\\\\\\\\') {
                  email.labels.push('חשוב');
                } else if (lowerLabel === 'inbox') {
                  email.labels.push('דואר נכנס');
                } else if (lowerLabel === 'sent') {
                  email.labels.push('נשלח');
                } else if (lowerLabel === 'starred') {
                  email.labels.push('מסומן בכוכב');
                } else if (label.length <= 15) {
                  email.labels.push(label);
                }
              }
            } else {
              email.labels = [folder === 'inbox' ? 'דואר נכנס' : 'נשלח'];
            }
            
            attributesSet = true;`;
    
    content = content.replace(startPattern, newLabelsCode);
    fs.writeFileSync('server.js', content);
    console.log('Labels code replaced successfully!');
} else {
    console.log('Could not find labels code to replace');
}
ENDSCRIPT

node replace-labels.js && rm replace-labels.js && pm2 restart site2-backend && pm2 logs site2-backend --lines 10"

echo.
echo ================================================
echo   ✅ קוד התוויות הוחלף!
echo ================================================
echo.
echo השינויים:
echo - טיפול ישיר בסלאש בסוף
echo - קוד פשוט וברור יותר
echo - תרגום Important בכל הצורות
echo.
echo רענן את האתר עכשיו!
echo.
pause