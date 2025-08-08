@echo off
echo ================================================
echo   תיקון סופי לתוויות - ישירות בשרת
echo ================================================
echo.

echo [1] מתקן את הקוד ישירות ב-site2...
echo ================================

ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cp server.js server.js.backup && cat > fix-final.js << 'EOF'
const fs = require('fs');

let content = fs.readFileSync('server.js', 'utf8');

// מחפש את כל החלק של התוויות
const startIndex = content.indexOf('// שלוף תוויות Gmail');
const endIndex = content.indexOf('attributesSet = true;', startIndex) + 'attributesSet = true;'.length;

if (startIndex > -1 && endIndex > startIndex) {
    const newLabelCode = `// שלוף תוויות Gmail
            if (attrs['x-gm-labels']) {
              console.log('Raw labels from Gmail:', attrs['x-gm-labels']);
              
              email.labels = attrs['x-gm-labels']
                .map(label => {
                  // נקה את התווית
                  label = String(label).trim();
                  
                  // הסר סלאש מהסוף
                  if (label.endsWith('\\\\')) {
                    label = label.slice(0, -1);
                  }
                  
                  // הסר תווים מיוחדים בהתחלה ובסוף
                  label = label.replace(/^[\\\\-]+|[\\\\-]+$/g, '');
                  
                  console.log('Processing label:', label);
                  
                  // סנן תוויות לא רצויות
                  if (label.includes('&') || label.startsWith('-') || label.length > 30) {
                    return null;
                  }
                  
                  // מילון תרגומים
                  const translations = {
                    'Important': 'חשוב',
                    'important': 'חשוב',
                    'IMPORTANT': 'חשוב',
                    'Inbox': 'דואר נכנס',
                    'INBOX': 'דואר נכנס',
                    'Sent': 'נשלח',
                    'SENT': 'נשלח',
                    'Draft': 'טיוטה',
                    'DRAFT': 'טיוטה',
                    'Spam': 'ספאם',
                    'SPAM': 'ספאם',
                    'Trash': 'אשפה',
                    'TRASH': 'אשפה',
                    'Starred': 'מסומן בכוכב',
                    'STARRED': 'מסומן בכוכב',
                    'Unread': 'לא נקרא',
                    'UNREAD': 'לא נקרא'
                  };
                  
                  // נסה למצוא תרגום
                  for (const [key, value] of Object.entries(translations)) {
                    if (label.toLowerCase() === key.toLowerCase()) {
                      return value;
                    }
                  }
                  
                  // אם אין תרגום, החזר את המקור רק אם הוא קצר
                  return label.length <= 15 ? label : null;
                })
                .filter(label => label !== null);
                
              console.log('Final labels:', email.labels);
            } else {
              email.labels = [folder === 'inbox' ? 'דואר נכנס' : folder === 'sent' ? 'נשלח' : folder];
            }
            
            attributesSet = true;`;
    
    // החלף את הקוד
    const before = content.substring(0, startIndex);
    const after = content.substring(endIndex);
    content = before + newLabelCode + after;
    
    fs.writeFileSync('server.js', content);
    console.log('Labels code fixed successfully!');
} else {
    console.log('Could not find labels section!');
}
EOF

node fix-final.js && rm fix-final.js"

echo.
echo [2] מפעיל מחדש את site2...
echo ================================

ssh root@31.97.129.5 "pm2 restart site2-backend && pm2 status | grep site2"

echo.
echo [3] בודק את התיקון...
echo ================================

timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "grep -A5 'Important' /home/emailapp/site2/backend/server.js | head -10"

echo.
echo ================================================
echo   ✅ התיקון הסופי הוחל!
echo ================================================
echo.
echo מה תוקן:
echo 1. הסרת סלאש מסוף התוויות (Important\ -> Important)
echo 2. ניקוי תווים מיוחדים
echo 3. תרגום case-insensitive (גם Important וגם important)
echo 4. הוספת לוגים לדיבאג
echo.
echo עכשיו:
echo 1. רענן את הדף (Ctrl+F5)
echo 2. פתח מייל חדש
echo 3. התוויות אמורות להיות בעברית!
echo.
pause