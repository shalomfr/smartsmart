@echo off
echo ================================================
echo   תיקון בעיית התוויות - ישירות בשרת
echo ================================================
echo.

echo מתחבר לשרת ומתקן...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cat > fix-labels.js << 'EOF'
const fs = require('fs');

// קרא את server.js
let content = fs.readFileSync('server.js', 'utf8');

// מצא את החלק של התוויות
const labelSection = content.match(/\/\/ שלוף תוויות Gmail[\s\S]*?attributesSet = true;/);

if (labelSection) {
    const newLabelCode = `// שלוף תוויות Gmail
            if (attrs['x-gm-labels']) {
              email.labels = attrs['x-gm-labels']
                .map(label => {
                  // הסר סלאש מהסוף אם יש
                  label = label.replace(/\\\\$/, '');
                  
                  // סנן תוויות עם תווים מוזרים
                  if (label.startsWith('-') || label.includes('&') || label.length > 50) {
                    return null;
                  }
                  
                  // תרגומים לעברית
                  const translations = {
                    'Important': 'חשוב',
                    'important': 'חשוב',
                    'IMPORTANT': 'חשוב',
                    'Inbox': 'דואר נכנס',
                    'INBOX': 'דואר נכנס',
                    'CATEGORY_SOCIAL': 'רשתות חברתיות',
                    'CATEGORY_PROMOTIONS': 'מבצעים',
                    'CATEGORY_UPDATES': 'עדכונים',
                    'CATEGORY_FORUMS': 'פורומים',
                    'CATEGORY_PERSONAL': 'אישי',
                    'CATEGORY_PRIMARY': 'ראשי',
                    'Unread': 'לא נקרא',
                    'UNREAD': 'לא נקרא',
                    'Starred': 'מסומן בכוכב',
                    'STARRED': 'מסומן בכוכב',
                    'Draft': 'טיוטה',
                    'DRAFT': 'טיוטה',
                    'Sent': 'נשלח',
                    'SENT': 'נשלח',
                    'Spam': 'ספאם',
                    'SPAM': 'ספאם',
                    'Trash': 'אשפה',
                    'TRASH': 'אשפה'
                  };
                  
                  // החזר תרגום או את התווית המקורית אם קצרה
                  return translations[label] || (label.length <= 15 ? label : null);
                })
                .filter(label => label !== null);
            } else {
              email.labels = [folder === 'inbox' ? 'דואר נכנס' : folder === 'sent' ? 'נשלח' : folder];
            }
            
            attributesSet = true;`;
    
    // החלף את הקוד
    content = content.replace(/\/\/ שלוף תוויות Gmail[\s\S]*?attributesSet = true;/, newLabelCode);
    
    // שמור
    fs.writeFileSync('server.js', content);
    console.log('Fixed labels code!');
} else {
    console.log('Could not find labels section!');
}
EOF

node fix-labels.js && rm fix-labels.js && pm2 restart site2-backend"

echo.
echo [בודק סטטוס...]
timeout /t 3 /nobreak >nul
ssh root@31.97.129.5 "pm2 status | grep site2-backend"

echo.
echo ================================================
echo   ✅ התוויות תוקנו!
echo ================================================
echo.
echo השיפורים:
echo 1. הסרת סלאש מסוף התוויות (Important\ -> Important)
echo 2. תרגום Important לחשוב
echo 3. סינון קודים מוזרים
echo.
echo רענן את הדף ב: http://31.97.129.5:8081
echo.
pause