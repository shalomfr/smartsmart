@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *     תיקון בעיית API - מחזיר HTML במקום JSON    *
echo ****************************************************
echo.

echo [1] בודק מה רץ על פורט 8082...
echo =================================
ssh root@31.97.129.5 "netstat -tlnp | grep 8082"

echo.
echo [2] הבעיה: ה-Frontend רץ על 8082, לא ה-Backend!
echo ==================================================
echo כשאתה פונה ל: http://31.97.129.5:8082/api/...
echo אתה מקבל את ה-HTML של ה-Frontend במקום API!
echo.

echo [3] הפתרון: להגדיר proxy נכון או לפנות ישירות ל-Backend...
echo ==============================================================
echo.

echo מעדכן את AuthContext לפנות ישירות לפורט 4000...
(
echo import { createContext, useContext, useState, useEffect } from 'react';
echo.
echo const AuthContext = createContext^(^);
echo.
echo export function useAuth^(^) {
echo   const context = useContext^(AuthContext^);
echo   if ^(!context^) {
echo     throw new Error^('useAuth must be used within an AuthProvider'^);
echo   }
echo   return context;
echo }
echo.
echo export function AuthProvider^({ children }^) {
echo   const [user, setUser] = useState^(null^);
echo   const [loading, setLoading] = useState^(true^);
echo.
echo   useEffect^(^(^) =^> {
echo     const storedUser = localStorage.getItem^('user'^);
echo     const authToken = localStorage.getItem^('authToken'^);
echo     if ^(storedUser ^&^& authToken^) {
echo       setUser^(JSON.parse^(storedUser^)^);
echo     }
echo     setLoading^(false^);
echo   }, []^);
echo.
echo   const login = async ^(username, password^) =^> {
echo     try {
echo       // תמיד פונה ישירות ל-Backend על פורט 4000
echo       const response = await fetch^('http://31.97.129.5:4000/api/app/login', {
echo         method: 'POST',
echo         headers: { 'Content-Type': 'application/json' },
echo         body: JSON.stringify^({ username, password }^),
echo       }^);
echo.
echo       const data = await response.json^(^);
echo.
echo       if ^(response.ok ^&^& data.success^) {
echo         setUser^(data.user^);
echo         localStorage.setItem^('user', JSON.stringify^(data.user^)^);
echo         localStorage.setItem^('authToken', data.token^);
echo         return true;
echo       }
echo       return false;
echo     } catch ^(error^) {
echo       console.error^('Login error:', error^);
echo       return false;
echo     }
echo   };
echo.
echo   const logout = ^(^) =^> {
echo     setUser^(null^);
echo     localStorage.removeItem^('user'^);
echo     localStorage.removeItem^('authToken'^);
echo   };
echo.
echo   const isAuthenticated = ^(^) =^> !!user;
echo.
echo   return ^(
echo     ^<AuthContext.Provider value={{ user, login, logout, isAuthenticated, loading }}^>
echo       {children}
echo     ^</AuthContext.Provider^>
echo   ^);
echo }
) > src\contexts\AuthContext.jsx

echo.
echo [4] מעלה לשרת...
echo =================
scp src/contexts/AuthContext.jsx root@31.97.129.5:/home/emailapp/site2/src/contexts/

echo.
echo [5] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [6] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart site2-frontend"

echo.
echo ****************************************************
echo *              תיקון הושלם!                       *
echo ****************************************************
echo.
echo עכשיו ה-Frontend יפנה ישירות ל:
echo http://31.97.129.5:4000/api/app/login
echo.
echo המתן 5 שניות ונסה שוב:
echo http://31.97.129.5:8082
echo.
echo admin / 123456
echo.
pause