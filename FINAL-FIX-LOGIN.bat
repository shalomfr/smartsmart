@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *         תיקון סופי לבעיית הכניסה               *
echo ****************************************************
echo.

echo שלב 1: בודק מה הבעיה...
echo ========================
echo.
echo נבדוק אם ה-API עובד:
ssh root@31.97.129.5 "curl -s -X POST http://localhost:4000/api/app/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}' | grep success"

echo.
echo אם ראית "success":true - ה-Backend בסדר!
echo.
pause

echo.
echo שלב 2: מתקן את ה-Frontend...
echo ============================
echo.

REM יוצר AuthContext.jsx מתוקן
(
echo import { createContext, useContext, useState, useEffect } from 'react';
echo.
echo const AuthContext = createContext();
echo.
echo export function useAuth() {
echo   const context = useContext(AuthContext);
echo   if (!context) {
echo     throw new Error('useAuth must be used within an AuthProvider');
echo   }
echo   return context;
echo }
echo.
echo export function AuthProvider({ children }) {
echo   const [user, setUser] = useState(null);
echo   const [loading, setLoading] = useState(true);
echo.
echo   useEffect(() =^> {
echo     const storedUser = localStorage.getItem('user');
echo     const authToken = localStorage.getItem('authToken');
echo     if (storedUser ^&^& authToken) {
echo       setUser(JSON.parse(storedUser));
echo     }
echo     setLoading(false);
echo   }, []);
echo.
echo   const login = async (username, password) =^> {
echo     try {
echo       const API_URL = 'http://31.97.129.5:4000/api';
echo       const response = await fetch(`${API_URL}/app/login`, {
echo         method: 'POST',
echo         headers: { 'Content-Type': 'application/json' },
echo         body: JSON.stringify({ username, password }),
echo       });
echo       const data = await response.json();
echo       if (response.ok ^&^& data.success) {
echo         setUser(data.user);
echo         localStorage.setItem('user', JSON.stringify(data.user));
echo         localStorage.setItem('authToken', data.token);
echo         return true;
echo       }
echo       return false;
echo     } catch (error) {
echo       console.error('Login error:', error);
echo       return false;
echo     }
echo   };
echo.
echo   const logout = () =^> {
echo     setUser(null);
echo     localStorage.removeItem('user');
echo     localStorage.removeItem('authToken');
echo   };
echo.
echo   const isAuthenticated = () =^> !!user;
echo.
echo   return (
echo     ^<AuthContext.Provider value={{ user, login, logout, isAuthenticated, loading }}^>
echo       {children}
echo     ^</AuthContext.Provider^>
echo   );
echo }
) > AuthContext.jsx.new

echo מעלה קובץ מתוקן...
scp AuthContext.jsx.new root@31.97.129.5:/home/emailapp/site2/src/contexts/AuthContext.jsx

echo.
echo שלב 3: בונה מחדש...
echo ====================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo שלב 4: מפעיל מחדש...
echo ====================
ssh root@31.97.129.5 "pm2 restart site2-frontend"

echo.
echo ****************************************************
echo *              סיימנו! 🎉                        *
echo ****************************************************
echo.
echo המתן 5 שניות ואז:
echo.
echo 1. נקה מטמון דפדפן (Ctrl+Shift+Delete)
echo 2. סגור את הדפדפן
echo 3. פתח דפדפן חדש
echo 4. היכנס ל: http://31.97.129.5:8082
echo.
echo כניסה:
echo   שם משתמש: admin
echo   סיסמה: 123456
echo.
pause