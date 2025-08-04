# הוראות התקנה - Email Client

## דרישות מקדימות
- Node.js 18+ 
- Git
- חשבון אימייל עם סיסמת אפליקציה

## התקנה מקומית

### 1. התקנת dependencies
```bash
# התקן את כל החבילות
npm install

# התקן חבילות backend
cd backend
npm install
cd ..
```

### 2. הגדרת משתני סביבה
צור קובץ `backend/.env` עם התוכן הבא:
```
PORT=3001
NODE_ENV=production

# הגדרות אימייל
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
IMAP_HOST=imap.gmail.com
IMAP_PORT=993
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587

# Claude AI (אופציונלי)
CLAUDE_API_KEY=your-claude-api-key

# Security
JWT_SECRET=your-secret-key-here
```

### 3. הרצה מקומית
```bash
# אפשרות 1: דרך הסקריפט
START_APP.bat

# אפשרות 2: ידנית
# Terminal 1 - Backend:
cd backend
node server.js

# Terminal 2 - Frontend:
npm run dev
```

## פריסה ל-VPS

### 1. העלאה ל-GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### 2. הגדרת GitHub Secrets
הוסף את המפתחות הבאים ב-Settings > Secrets:
- `VPS_HOST`: כתובת IP של השרת
- `VPS_USER`: emailapp
- `VPS_PORT`: 22
- `VPS_SSH_KEY`: המפתח הפרטי SSH

### 3. התקנה ב-VPS
הרץ את הסקריפט `setup-vps-for-deployment.sh` בשרת

## מבנה הפרויקט
```
├── backend/          # שרת Express.js
├── src/              # קוד React
│   ├── pages/        # דפי האפליקציה
│   ├── components/   # רכיבי UI
│   └── api/          # API clients
├── .github/          # GitHub Actions
└── START_APP.bat     # סקריפט הפעלה
```

## פיצ'רים עיקריים
- ✅ דואר נכנס
- ✅ שליחת מיילים
- ✅ אנשי קשר
- ✅ פיצ'רים חכמים
- ✅ אימון AI
- ✅ כללים אוטומטיים

## בעיות נפוצות

### שגיאת Permission Denied ב-Linux
```bash
chmod 755 /home/emailapp
chmod -R 755 /home/emailapp/email-app/dist
usermod -a -G emailapp www-data
```

### שגיאת Case Sensitivity
השתמש ב-`fix-all-imports.py` לתיקון אוטומטי

## תמיכה
לשאלות ובעיות, פתח Issue ב-GitHub