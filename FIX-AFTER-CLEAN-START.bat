@echo off
chcp 65001 >nul
cls
color 0C
echo ****************************************************
echo *      תיקון אחרי CLEAN-START                     *
echo ****************************************************
echo.

echo [1] בודק מה רץ...
echo ==================
ssh root@31.97.129.5 "pm2 list | grep email"

echo.
echo [2] בודק פורטים...
echo ===================
ssh root@31.97.129.5 "netstat -tlnp | grep -E '(8081|4000)'"

echo.
echo [3] בודק את AuthContext בשרת...
echo =================================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/src/contexts && grep -n 'API_URL\\|fetch' AuthContext.jsx | head -10"

echo.
echo [4] מתקן את הבעיה בקובץ AuthContext...
echo ========================================
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
) > AuthContext.jsx.fixed

echo.
echo [5] מעלה לשרת...
echo =================
scp AuthContext.jsx.fixed root@31.97.129.5:/home/emailapp/email-prod/src/contexts/AuthContext.jsx

echo.
echo [6] מתקן API files...
echo ====================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod/src/api && for f in *.js; do sed -i 's|const API_URL = .*|const API_URL = '\''http://31.97.129.5:4000'\'';|' \$f; done"

echo.
echo [7] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/email-prod && npm run build"

echo.
echo [8] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart email-frontend email-backend"

echo.
echo ****************************************************
echo *              תיקון הושלם!                       *
echo ****************************************************
echo.
echo המתן 5 שניות ונסה:
echo http://31.97.129.5:8081
echo.
echo admin / 123456
echo.
pause