# מדריך הרצת מספר אתרים על VPS אחד

## 🎯 סקריפטים זמינים

### 1. ADD-NEW-SITE.bat - הוספת אתר חדש
מוסיף אתר חדש לשרת בלי לפגוע באתרים קיימים.

```bash
ADD-NEW-SITE.bat
```

**דוגמה:**
- שם אתר: `myapp`
- דומיין: `31.97.129.5:8081`
- Backend Port: `3002`
- Frontend Port: `8081`

### 2. MANAGE-ALL-SITES.bat - ניהול אתרים
תפריט אינטראקטיבי לניהול כל האתרים.

```bash
MANAGE-ALL-SITES.bat
```

**אפשרויות:**
- הצג את כל האתרים
- הפעל מחדש אתר
- עצור אתר
- הצג לוגים
- מחק אתר

### 3. CHECK-ALL-SITES.bat - בדיקת סטטוס
בדיקה מהירה של כל האתרים והשירותים.

```bash
CHECK-ALL-SITES.bat
```

## 🌐 דוגמה למספר אתרים

### אתר 1 - Email App (קיים)
- **תיקייה:** `/home/emailapp/email-app`
- **Backend:** Port 3001
- **Frontend:** Port 8080
- **גישה:** http://31.97.129.5

### אתר 2 - My App
- **תיקייה:** `/home/emailapp/myapp`
- **Backend:** Port 3002
- **Frontend:** Port 8081
- **גישה:** http://31.97.129.5:8081

### אתר 3 - Test Site
- **תיקייה:** `/home/emailapp/test`
- **Backend:** Port 3003
- **Frontend:** Port 8082
- **גישה:** http://31.97.129.5:8082

## 🔧 פקודות שימושיות

### ראה את כל התהליכים
```bash
ssh root@31.97.129.5 "pm2 list"
```

### ראה את כל אתרי Nginx
```bash
ssh root@31.97.129.5 "ls -la /etc/nginx/sites-enabled/"
```

### בדוק פורטים פתוחים
```bash
ssh root@31.97.129.5 "netstat -tlnp | grep LISTEN"
```

## 📝 הערות חשובות

1. **פורטים:** וודא שכל אתר משתמש בפורטים ייחודיים
2. **זיכרון:** בדוק שיש מספיק זיכרון RAM לכל האתרים
3. **דומיינים:** אפשר להשתמש בדומיינים שונים במקום פורטים
4. **SSL:** אפשר להוסיף SSL לכל אתר בנפרד

## 🚀 התחלה מהירה

1. הוסף אתר חדש:
   ```bash
   ADD-NEW-SITE.bat
   ```

2. בדוק שהכל עובד:
   ```bash
   CHECK-ALL-SITES.bat
   ```

3. נהל את האתרים:
   ```bash
   MANAGE-ALL-SITES.bat
   ```

## 🆘 פתרון בעיות

### אתר לא עולה?
1. בדוק פורטים תפוסים
2. בדוק לוגים: `pm2 logs [site-name]-backend`
3. בדוק Nginx: `nginx -t`

### חוסר זיכרון?
1. הוסף Swap: `fallocate -l 2G /swapfile`
2. הגדל את ה-VPS
3. עצור אתרים שלא בשימוש

## 💡 טיפים

- השתמש בשמות ברורים לאתרים
- תעד את הפורטים שבשימוש
- עשה גיבויים לפני שינויים
- בדוק סטטוס באופן קבוע