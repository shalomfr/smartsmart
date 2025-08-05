# הוראות פריסה מלאות - Email App

## פרטי השרת
- **IP**: 31.97.129.5
- **משתמש**: root
- **תיקיית האפליקציה**: /home/emailapp/email-app
- **GitHub Repository**: https://github.com/shalomfr/smartsmart

## סקריפטים זמינים

### 1. פריסה מלאה (Windows)
```bash
# באמצעות Batch
deploy-to-github-and-vps.bat

# באמצעות PowerShell
.\deploy-complete.ps1
```

### 2. פריסה מלאה (Linux/Mac)
```bash
chmod +x deploy-to-vps.sh
./deploy-to-vps.sh
```

### 3. התקנה ראשונית ב-VPS (רק פעם אחת)
העתק את `vps-initial-setup.sh` לשרת והרץ:
```bash
scp vps-initial-setup.sh root@31.97.129.5:/tmp/
ssh root@31.97.129.5 "bash /tmp/vps-initial-setup.sh"
```

## תהליך הפריסה

הסקריפטים מבצעים אוטומטית:

1. **דחיפה ל-GitHub**:
   - `git add .`
   - `git commit`
   - `git push`

2. **פריסה ב-VPS**:
   - משיכת הקוד העדכני
   - התקנת חבילות (frontend + backend)
   - בניית הפרונטאנד
   - הפעלה מחדש עם PM2

## שמות השירותים ב-PM2
- **Backend**: email-app-backend (פורט 3001)
- **Frontend**: email-app-frontend (פורט 8080)

## פקודות שימושיות בשרת

### בדיקת סטטוס
```bash
ssh root@31.97.129.5 "pm2 status"
```

### צפייה בלוגים
```bash
# כל הלוגים
ssh root@31.97.129.5 "pm2 logs"

# רק backend
ssh root@31.97.129.5 "pm2 logs email-app-backend"

# רק frontend
ssh root@31.97.129.5 "pm2 logs email-app-frontend"
```

### הפעלה מחדש
```bash
# הכל
ssh root@31.97.129.5 "pm2 restart all"

# רק backend
ssh root@31.97.129.5 "pm2 restart email-app-backend"

# רק frontend
ssh root@31.97.129.5 "pm2 restart email-app-frontend"
```

### בדיקת Nginx
```bash
ssh root@31.97.129.5 "nginx -t"
ssh root@31.97.129.5 "systemctl status nginx"
```

## בעיות נפוצות ופתרונות

### שגיאת 500/502
```bash
# בדוק אם השירותים פועלים
ssh root@31.97.129.5 "pm2 status"

# בדוק פורטים
ssh root@31.97.129.5 "netstat -tlnp | grep -E '3001|8080'"

# בדוק לוגים של Nginx
ssh root@31.97.129.5 "tail -50 /var/log/nginx/error.log"
```

### אם הפורטים תפוסים
```bash
ssh root@31.97.129.5 "lsof -ti:3001 | xargs kill -9"
ssh root@31.97.129.5 "lsof -ti:8080 | xargs kill -9"
```

### התקנה נקייה מחדש
```bash
fresh-install-fix.bat
```

## מבנה הפרויקט בשרת
```
/home/emailapp/email-app/
├── backend/
│   ├── server.js
│   ├── package.json
│   └── .env
├── dist/           # הפרונטאנד הבנוי
├── src/            # קוד המקור
└── package.json
```

## הגדרות Nginx
הקובץ נמצא ב: `/etc/nginx/sites-available/email-app`
- Frontend: מוגש מ-`/home/emailapp/email-app/dist`
- Backend API: פרוקסי ל-`localhost:3001`

## עדכון אוטומטי
הסקריפטים כוללים:
- בדיקת git אוטומטית
- יצירת commit עם חותמת זמן
- push אוטומטי (כולל force אם צריך)
- pull אוטומטי בשרת
- הפעלה מחדש אוטומטית

כל מה שצריך זה להריץ את אחד הסקריפטים!