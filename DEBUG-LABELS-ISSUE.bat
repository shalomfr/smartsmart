@echo off
echo ================================================
echo   אבחון בעיית התוויות
echo ================================================
echo.

echo [1] בודק מה יש בשרת עכשיו...
echo ================================

ssh root@31.97.129.5 "echo 'Checking site2 labels code:' && grep -B2 -A15 'x-gm-labels' /home/emailapp/site2/backend/server.js | head -20"

echo.
echo [2] בודק אם יש סלאשים בקוד...
echo ================================

ssh root@31.97.129.5 "grep -n 'Important' /home/emailapp/site2/backend/server.js || echo 'No Important found in code'"

echo.
echo [3] בודק לוגים אחרונים...
echo ================================

ssh root@31.97.129.5 "pm2 logs site2-backend --lines 30 --nostream | grep -E 'label|Important|תווית' || echo 'No label logs'"

echo.
echo [4] בודק מה מגיע מ-Gmail...
echo ================================

ssh root@31.97.129.5 "cd /home/emailapp/site2/backend && cat > debug-labels.js << 'EOF'
// הוסף לוג לקוד כדי לראות מה מגיע
const fs = require('fs');
let content = fs.readFileSync('server.js', 'utf8');

// הוסף console.log אחרי x-gm-labels
content = content.replace(
  \"if (attrs['x-gm-labels']) {\",
  \"if (attrs['x-gm-labels']) {\\n              console.log('Raw Gmail labels:', attrs['x-gm-labels']);\"
);

// הוסף לוג אחרי המיפוי
content = content.replace(
  \".filter(label => label !== null);\",
  \".filter(label => label !== null);\\n              console.log('Processed labels:', email.labels);\"
);

fs.writeFileSync('server.js', content);
console.log('Debug logging added!');
EOF

node debug-labels.js && rm debug-labels.js && pm2 restart site2-backend"

echo.
echo ================================================
echo   הלוגים נוספו! עכשיו:
echo ================================================
echo.
echo 1. רענן את הדף באתר
echo 2. פתח מייל עם תוויות
echo 3. חזור לכאן ולחץ Enter
echo.
pause

echo.
echo [5] מציג את הלוגים החדשים...
echo ================================

ssh root@31.97.129.5 "pm2 logs site2-backend --lines 50 --nostream | grep -E 'Raw Gmail labels|Processed labels' | tail -20"

echo.
echo ================================================
echo   מה מצאנו?
echo ================================================
echo.
echo אם ראית:
echo - Raw Gmail labels עם סלאש בסוף
echo - Processed labels ללא תרגום
echo.
echo אז הבעיה ברורה והתיקון לא הוחל
echo.
pause