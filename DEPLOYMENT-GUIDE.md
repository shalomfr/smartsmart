# 🚀 מדריך העלאה לשרת - Deployment Guide

## 📋 מבנה השרת

**כתובת השרת:** `31.97.129.5`  
**משתמש:** `root`  
**נתיב הפרויקט:** `/home/emailapp/email-prod/`

**מבנה תיקיות:**
```
/home/emailapp/email-prod/
├── backend/
│   └── server.js          # קובץ השרת הראשי
├── dist/                  # קבצי הפרונטאנד הבנויים
│   ├── index.html
│   ├── assets/
│   │   ├── index-*.js
│   │   └── index-*.css
└── package.json
```

## 🔧 תהליך העלאה מלא

### 1️⃣ העלאת קובץ השרת בלבד

```bash
# העלאת backend/server.js
scp backend/server.js root@31.97.129.5:/home/emailapp/email-prod/backend/server.js

# הפעלה מחדש של השרת
ssh root@31.97.129.5 "pm2 restart email-backend"
```

### 2️⃣ העלאת הפרונטאנד בלבד

```bash
# בניית הפרונטאנד
npm run build

# העלאת קבצי הפרונטאנד
scp -r dist/* root@31.97.129.5:/home/emailapp/email-prod/dist/
```

### 3️⃣ העלאה מלאה (פרונטאנד + בקאנד)

```bash
# בניית הפרונטאנד
npm run build

# העלאת הבקאנד
scp backend/server.js root@31.97.129.5:/home/emailapp/email-prod/backend/server.js

# העלאת הפרונטאנד
scp -r dist/* root@31.97.129.5:/home/emailapp/email-prod/dist/

# הפעלה מחדש של השרת
ssh root@31.97.129.5 "pm2 restart email-backend"
```

## 🔄 פקודות PM2 לניהול השרת

### בדיקת סטטוס
```bash
ssh root@31.97.129.5 "pm2 status"
```

### הפעלה מחדש של השרת
```bash
ssh root@31.97.129.5 "pm2 restart email-backend"
```

### צפייה בלוגים
```bash
# לוגים כלליים
ssh root@31.97.129.5 "pm2 logs email-backend --lines 20"

# לוגים בזמן אמת
ssh root@31.97.129.5 "pm2 logs email-backend --follow"

# חיפוש בלוגים
ssh root@31.97.129.5 "pm2 logs email-backend --lines 50 | grep ERROR"
```

### עצירה והפעלה
```bash
# עצירת השרת
ssh root@31.97.129.5 "pm2 stop email-backend"

# הפעלת השרת
ssh root@31.97.129.5 "pm2 start email-backend"

# הפעלה מחדש של כל השירותים
ssh root@31.97.129.5 "pm2 restart all"
```

## 📦 סקריפטים מוכנים

### QUICK-DEPLOY.bat (העלאה מהירה)
```batch
@echo off
echo ===============================================
echo        העלאה מהירה לשרת
echo ===============================================

echo [1] בונה את הפרונטאנד...
npm run build

echo [2] מעלה את השרת...
scp backend/server.js root@31.97.129.5:/home/emailapp/email-prod/backend/server.js

echo [3] מעלה את הפרונטאנד...
scp -r dist/* root@31.97.129.5:/home/emailapp/email-prod/dist/

echo [4] מפעיל מחדש את השרת...
ssh root@31.97.129.5 "pm2 restart email-backend"

echo ✅ העלאה הושלמה בהצלחה!
echo 🌐 האתר זמין בכתובת: http://31.97.129.5:8081
pause
```

### DEPLOY-BACKEND-ONLY.bat (רק שרת)
```batch
@echo off
echo ===============================================
echo        העלאת שרת בלבד
echo ===============================================

echo [1] מעלה את קובץ השרת...
scp backend/server.js root@31.97.129.5:/home/emailapp/email-prod/backend/server.js

echo [2] מפעיל מחדש...
ssh root@31.97.129.5 "pm2 restart email-backend"

echo ✅ השרת עודכן בהצלחה!
pause
```

### CHECK-SERVER-STATUS.bat (בדיקת סטטוס)
```batch
@echo off
echo ===============================================
echo        בדיקת סטטוס השרת
echo ===============================================

echo [1] סטטוס PM2:
ssh root@31.97.129.5 "pm2 status"

echo.
echo [2] לוגים אחרונים:
ssh root@31.97.129.5 "pm2 logs email-backend --lines 10"

echo.
echo [3] בדיקת חיבור:
curl -I http://31.97.129.5:8081

pause
```

## 🐛 פתרון בעיות נפוצות

### השרת לא מגיב
```bash
# בדוק אם השירות פועל
ssh root@31.97.129.5 "pm2 status"

# הפעל מחדש אם נפל
ssh root@31.97.129.5 "pm2 restart email-backend"
```

### שגיאות בקוד
```bash
# בדוק שגיאות בלוגים
ssh root@31.97.129.5 "pm2 logs email-backend --lines 50 | grep -i error"

# בדוק syntax errors
node -c backend/server.js
```

### בעיות הרשאות
```bash
# תקן הרשאות אם נדרש
ssh root@31.97.129.5 "chmod -R 755 /home/emailapp/email-prod/"
```

### cache של הדפדפן
- רענן עם **Ctrl+Shift+R**
- או נקה cache ידנית

## 📍 כתובות חשובות

- **אתר בפרודקשן:** http://31.97.129.5:8081
- **לוקאלי:** http://localhost:3000 (פיתוח)
- **API בפרודקשן:** http://31.97.129.5:4000

## ⚡ זרימת עבודה מהירה

**לתיקונים קטנים בשרת:**
1. ערוך את `backend/server.js`
2. הרץ: `DEPLOY-BACKEND-ONLY.bat`

**לתיקונים בפרונטאנד:**
1. ערוך קבצי React ב-`src/`
2. הרץ: `npm run build`
3. הרץ: `scp -r dist/* root@31.97.129.5:/home/emailapp/email-prod/dist/`

**לתיקונים גדולים:**
1. ערוך את הקבצים הנדרשים
2. הרץ: `QUICK-DEPLOY.bat`

## 🔍 בדיקות לאחר העלאה

1. **בדוק סטטוס:** `CHECK-SERVER-STATUS.bat`
2. **בדוק באתר:** http://31.97.129.5:8081
3. **בדוק פונקציונליות:** התחבר ונסה לשלוח מייל
4. **בדוק לוגים:** אם יש שגיאות

---

💡 **טיפ:** שמור את הקבצים האלו בתיקיית הפרויקט לשימוש עתידי!