@echo off
echo ===== הגדרת GitHub Action =====
echo.

echo [1] בודק אם יש SSH key...
if exist %USERPROFILE%\.ssh\id_rsa (
    echo    [V] נמצא SSH key קיים
) else (
    echo    [!] יוצר SSH key חדש...
    ssh-keygen -t rsa -b 4096 -f %USERPROFILE%\.ssh\id_rsa -N ""
    echo    [V] SSH key נוצר
)

echo.
echo [2] מעתיק את המפתח הציבורי לשרת...
ssh-copy-id root@31.97.129.5 2>nul
if errorlevel 1 (
    echo    [!] כבר קיים או נכשל - זה בסדר
) else (
    echo    [V] הועתק בהצלחה
)

echo.
echo [3] המפתח הפרטי שלך:
echo ===============================
type %USERPROFILE%\.ssh\id_rsa
echo ===============================
echo.

echo [4] מה לעשות עכשיו:
echo.
echo 1. העתק את כל המפתח למעלה (כולל BEGIN ו-END)
echo 2. לך ל: https://github.com/shalomfr/smartsmart/settings/secrets/actions
echo 3. לחץ "New repository secret"
echo 4. Name: VPS_SSH_KEY
echo 5. Value: הדבק את המפתח
echo 6. לחץ "Add secret"
echo.
echo 7. דחוף את קובץ ה-workflow:
echo    git add .github/workflows/deploy.yml
echo    git commit -m "Add GitHub Action"
echo    git push
echo.
echo ===== זהו! מעכשיו כל push יפרוס אוטומטית =====
echo.
pause