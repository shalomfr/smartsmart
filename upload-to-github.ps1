# סקריפט PowerShell להעלאת שינויים לגיטהאב
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   מעלה עדכון הגדרות מוצפנות לגיט" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# עובר לתיקייה
Set-Location "C:\mail\0548481658"

# בודק אם יש שינויים
Write-Host "🔍 בודק שינויים..." -ForegroundColor Yellow
$changes = git status --porcelain
if ($changes) {
    Write-Host "✅ נמצאו שינויים:" -ForegroundColor Green
    git status --short
} else {
    Write-Host "❌ אין שינויים להעלות" -ForegroundColor Red
    Read-Host "לחץ Enter לסיום"
    exit
}

Write-Host ""

# מוסיף שינויים
Write-Host "📁 מוסיף שינויים..." -ForegroundColor Yellow
git add -A

# יוצר commit
Write-Host "💾 יוצר commit..." -ForegroundColor Yellow
git commit -m "Add encrypted server settings - save and load credentials securely"

Write-Host ""

# מעלה לגיטהאב
Write-Host "🚀 מעלה לגיטהאב..." -ForegroundColor Yellow
try {
    git push origin main
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Green
    Write-Host "✅ הועלה בהצלחה!" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Green
    
    # מעדכן שרת
    Write-Host ""
    Write-Host "🔄 מעדכן את השרת..." -ForegroundColor Yellow
    ssh root@31.97.129.5 "cd /home/emailapp/email-app && git pull && cd backend && npm install && pm2 restart email-app-backend"
    
    Write-Host ""
    Write-Host "✅ השרת עודכן בהצלחה!" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host "❌ שגיאה בהעלאה!" -ForegroundColor Red
    Write-Host "==============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "השגיאה:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message
    Write-Host ""
    Write-Host "פתרונות אפשריים:" -ForegroundColor Cyan
    Write-Host "1. ודא שאתה מחובר לגיטהאב"
    Write-Host "2. בדוק שיש לך הרשאות לריפוזיטורי"
    Write-Host "3. נסה: git config --global credential.helper manager"
}

Write-Host ""
Read-Host "לחץ Enter לסיום"