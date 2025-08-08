@echo off
echo ================================================
echo   תיקון מלא של מערכת התוויות
echo ================================================
echo.

echo [1] מחליף את כל קוד התוויות...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cp server.js server.js.backup-$(date +%%Y%%m%%d) && cat > fix-all-labels.js << 'EOF'
const fs = require('fs');
let content = fs.readFileSync('server.js', 'utf8');

// מצא את כל קטע התוויות
const start = content.indexOf('// שלוף תוויות Gmail');
const end = content.indexOf('attributesSet = true;', start) + 'attributesSet = true;'.length;

if (start > -1 && end > start) {
    const newLabelsCode = `// שלוף תוויות Gmail
            if (attrs['x-gm-labels']) {
              console.log('Gmail labels received:', attrs['x-gm-labels']);
              
              email.labels = [];
              const seenLabels = new Set(); // למנוע כפילויות
              
              for (let label of attrs['x-gm-labels']) {
                // המר לstring ונקה
                label = String(label).trim();
                
                // הסר סלאש כפול או בודד מהסוף
                label = label.replace(/\\\\\\\\+$/, '').replace(/\\\\$/, '');
                
                // הסר מקפים ותווים מיוחדים מההתחלה
                label = label.replace(/^[-_]+/, '');
                
                // דלג על תוויות עם קודים
                if (label.includes('&') || label.includes('\\\\x') || label.length > 50) {
                  continue;
                }
                
                // תרגומים - בדוק כל אפשרות
                let translated = null;
                const lowerLabel = label.toLowerCase();
                
                // תרגומים בסיסיים
                const translations = {
                  'important': 'חשוב',
                  'inbox': 'דואר נכנס',
                  'sent': 'נשלח',
                  'starred': 'מסומן בכוכב',
                  'unread': 'לא נקרא',
                  'drafts': 'טיוטות',
                  'draft': 'טיוטה',
                  'spam': 'ספאם',
                  'trash': 'אשפה',
                  'category_social': 'רשתות חברתיות',
                  'category_promotions': 'מבצעים',
                  'category_updates': 'עדכונים',
                  'category_forums': 'פורומים',
                  'category_personal': 'אישי',
                  'category_primary': 'ראשי'
                };
                
                // חפש תרגום
                for (const [key, value] of Object.entries(translations)) {
                  if (lowerLabel === key || lowerLabel === key + '\\\\\\\\') {
                    translated = value;
                    break;
                  }
                }
                
                // אם אין תרגום, השתמש במקור אם הוא קצר
                if (!translated && label.length <= 20 && !label.includes('\\\\')) {
                  translated = label;
                }
                
                // הוסף לרשימה אם לא כפילות
                if (translated && !seenLabels.has(translated)) {
                  email.labels.push(translated);
                  seenLabels.add(translated);
                }
              }
              
              console.log('Final labels:', email.labels);
            } else {
              email.labels = [folder === 'inbox' ? 'דואר נכנס' : folder === 'sent' ? 'נשלח' : folder];
            }
            
            attributesSet = true;`;
    
    const before = content.substring(0, start);
    const after = content.substring(end);
    content = before + newLabelsCode + after;
    
    fs.writeFileSync('server.js', content);
    console.log('Labels code completely replaced!');
} else {
    console.log('Could not find labels section');
}
EOF

node fix-all-labels.js && rm fix-all-labels.js"

echo.
echo [2] מפעיל מחדש...
ssh root@31.97.129.5 "pm2 restart site2-backend && pm2 flush site2-backend"

echo.
echo [3] בודק שהתיקון הוחל...
ssh root@31.97.129.5 "grep -A5 'Gmail labels received' /home/emailapp/site2/backend/server.js"

echo.
echo ================================================
echo   ✅ התיקון המלא הוחל!
echo ================================================
echo.
echo מה תוקן:
echo 1. טיפול בכל סוגי הסלאשים (\ ו-\\)
echo 2. הסרת תווים מיוחדים
echo 3. מניעת כפילויות
echo 4. לוגים מפורטים
echo.
echo עכשיו חובה:
echo 1. סגור את הדפדפן לגמרי
echo 2. פתח במצב גלישה בסתר (Ctrl+Shift+N)
echo 3. התחבר מחדש
echo 4. טען מיילים חדשים
echo.
pause