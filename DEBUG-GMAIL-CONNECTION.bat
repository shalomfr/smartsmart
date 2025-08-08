@echo off
echo ================================================
echo   בדיקת חיבור Gmail ותוויות
echo ================================================
echo.

echo [1] בודק הגדרות IMAP...
ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cat > test-imap.js << 'EOF'
// בדיקת הגדרות IMAP
const Imap = require('imap');

// צור חיבור בדיקה
const imap = new Imap({
  user: 'your-email@gmail.com', // החלף למייל שלך
  password: 'your-password', // החלף לסיסמה שלך
  host: 'imap.gmail.com',
  port: 993,
  tls: true,
  authTimeout: 10000,
  connTimeout: 30000,
  tlsOptions: { 
    rejectUnauthorized: false,
    servername: 'imap.gmail.com'
  }
});

imap.once('ready', () => {
  console.log('Connected to Gmail!');
  
  imap.openBox('INBOX', true, (err, box) => {
    if (err) {
      console.error('Error opening inbox:', err);
      imap.end();
      return;
    }
    
    console.log('Fetching last email...');
    const fetch = imap.seq.fetch(box.messages.total + ':*', {
      bodies: '',
      struct: true,
      envelope: true
    });
    
    fetch.on('message', (msg, seqno) => {
      msg.once('attributes', (attrs) => {
        console.log('\\n=== Email Attributes ===');
        console.log('Flags:', attrs.flags);
        console.log('X-GM-LABELS:', attrs['x-gm-labels']);
        console.log('X-GM-THRID:', attrs['x-gm-thrid']);
        console.log('========================\\n');
      });
    });
    
    fetch.once('end', () => {
      console.log('Done fetching');
      imap.end();
    });
  });
});

imap.once('error', (err) => {
  console.error('IMAP Error:', err);
});

console.log('Update email and password in test-imap.js first!');
EOF

echo 'Check test-imap.js and update credentials'"

echo.
echo [2] או בדוק את הגדרת fetch הנוכחית...
ssh root@31.97.129.5 "grep -B5 -A5 'imap.seq.fetch' /home/emailapp/site2/backend/server.js | head -20"

echo.
echo ================================================
echo   הבעיה יכולה להיות:
echo ================================================
echo.
echo 1. חסר envelope: true בהגדרות fetch
echo 2. Gmail לא שולח x-gm-labels בגלל הגדרות IMAP
echo 3. צריך להפעיל "Show IMAP" ב-Gmail
echo.
echo פתרונות:
echo - ודא ש-IMAP מופעל בהגדרות Gmail
echo - ודא שיש גישה ל"Less secure apps" או App Password
echo - הרץ את FIX-ALL-LABELS.bat
echo.
pause