@echo off
chcp 65001 >nul
cls
color 0E
echo ****************************************************
echo *       הוספת משתמש בדיקה לשרת                   *
echo ****************************************************
echo.

echo [1] יוצר קובץ עם קוד תיקון...
echo ==============================
(
echo // הוסף את זה בתחילת הקובץ server.js אחרי ה-requires
echo const MOCK_USERS = [
echo   { email: 'test@example.com', password: '123456', name: 'Test User' },
echo   { email: 'admin@example.com', password: 'admin123', name: 'Admin User' },
echo   { email: 'user@example.com', password: 'password123', name: 'Regular User' }
echo ];
echo.
echo // החלף את פונקציית הלוגין הקיימת
echo app.post('/api/auth/login', async ^(req, res^) =^> {
echo   const { email, password } = req.body;
echo   
echo   // בדיקה במשתמשי בדיקה
echo   const mockUser = MOCK_USERS.find^(u =^> u.email === email ^&^& u.password === password^);
echo   if ^(mockUser^) {
echo     const token = jwt.sign^({ email: mockUser.email, name: mockUser.name }, JWT_SECRET, { expiresIn: '7d' }^);
echo     return res.json^({
echo       success: true,
echo       token,
echo       user: { email: mockUser.email, name: mockUser.name }
echo     }^);
echo   }
echo   
echo   // אם לא נמצא במשתמשי בדיקה, נסה IMAP
echo   try {
echo     // הקוד הקיים של IMAP...
) > mock-auth-code.txt

echo.
echo [2] מעלה את הקוד לשרת...
echo =========================
scp mock-auth-code.txt root@31.97.129.5:/home/emailapp/site2/backend/

echo.
echo [3] מראה את הקוד למשתמש...
echo ============================
type mock-auth-code.txt

echo.
echo ****************************************************
echo *             הוראות ידניות                      *
echo ****************************************************
echo.
echo צריך לערוך את הקובץ server.js בשרת ולהוסיף:
echo.
echo 1. בתחילת הקובץ (אחרי ה-requires):
echo    - את מערך MOCK_USERS
echo.
echo 2. להחליף את פונקציית /api/auth/login
echo    - כך שתבדוק קודם במשתמשי בדיקה
echo.
echo או פשוט נסה את המשתמש הבא שאולי כבר קיים:
echo.
echo אימייל: test@example.com
echo סיסמה: 123456
echo.
echo ****************************************************
echo.
pause