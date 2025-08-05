# 🚀 הגדרת GitHub Action לפריסה אוטומטית

## מה זה עושה?
בכל פעם שתדחוף קוד ל-GitHub, האתר יתעדכן אוטומטית בשרת!

## Workflows זמינים
יצרתי לך כמה אפשרויות:
- **deploy.yml** - פריסה מלאה עם כל הבדיקות
- **simple-deploy.yml** - פריסה פשוטה ומהירה
- **deploy-to-vps.yml** - פריסה מתקדמת עם cache
- **deploy-hostinger.yml** - פריסה ל-Hostinger

## הגדרה חד-פעמית

### 1. יצירת SSH Key (אם אין לך)

בטרמינל של Windows:
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```
- לחץ Enter לשמור במיקום ברירת המחדל
- אל תכניס passphrase (פשוט Enter)

### 2. העתקת המפתח הפרטי

```bash
type %USERPROFILE%\.ssh\id_rsa
```

העתק את כל התוכן כולל:
```
-----BEGIN RSA PRIVATE KEY-----
[התוכן שלך כאן]
-----END RSA PRIVATE KEY-----
```

### 3. הוספת המפתח ל-GitHub

1. לך ל: https://github.com/shalomfr/smartsmart/settings/secrets/actions
2. לחץ על "New repository secret"
3. הגדר:
   - **Name**: `VPS_SSH_KEY`
   - **Value**: הדבק את המפתח הפרטי שהעתקת
4. לחץ "Add secret"

### 4. הוספת המפתח הציבורי לשרת

אם עוד לא עשית:
```bash
ssh-copy-id root@31.97.129.5
```

או ידנית:
```bash
type %USERPROFILE%\.ssh\id_rsa.pub
```
והעתק את התוכן ל: `/root/.ssh/authorized_keys` בשרת

## בדיקה

### אפשרות 1 - פריסה ידנית:
1. לך ל: https://github.com/shalomfr/smartsmart/actions
2. לחץ על "Deploy to VPS"
3. לחץ על "Run workflow"
4. לחץ על "Run workflow" (הירוק)

### אפשרות 2 - פריסה אוטומטית:
פשוט דחוף קוד:
```bash
git add .
git commit -m "Test auto deploy"
git push
```

## מעקב אחרי הפריסה

1. לך ל: https://github.com/shalomfr/smartsmart/actions
2. תראה את הפריסה רצה
3. לחץ עליה לראות לוגים

## 🎉 זהו!

מעכשיו כל פעם שתעשה `git push`, האתר יתעדכן אוטומטית!

## בעיות נפוצות

### "Host key verification failed"
הרץ פעם אחת:
```bash
ssh root@31.97.129.5
```
ואשר את ה-fingerprint

### "Permission denied"
וודא שהמפתח הציבורי נמצא ב-`/root/.ssh/authorized_keys` בשרת

### הפריסה נכשלת
בדוק את הלוגים ב-Actions tab ב-GitHub