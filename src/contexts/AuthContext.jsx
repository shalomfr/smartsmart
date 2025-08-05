import { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext();

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // בדיקה אם המשתמש מחובר (בטעינה הראשונית)
  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    const authToken = localStorage.getItem('authToken');
    
    if (storedUser && authToken) {
      setUser(JSON.parse(storedUser));
    }
    setLoading(false);
  }, []);

  // פונקציית כניסה
  const login = async (username, password) => {
    try {
      // אם אתה בסביבת פיתוח מקומית, השתמש ב-localhost
      // אם אתה בשרת, החלף ל-IP של השרת
      const API_URL = window.location.hostname === 'localhost' 
        ? 'http://localhost:3001' 
        : 'http://31.97.129.5/api';
      
      const response = await fetch(`${API_URL}/app/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password }),
      });

      const data = await response.json();

      if (response.ok && data.success) {
        setUser(data.user);
        localStorage.setItem('user', JSON.stringify(data.user));
        localStorage.setItem('authToken', data.token);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      console.error('Login error:', error);
      return false;
    }
  };

  // פונקציית יציאה
  const logout = () => {
    setUser(null);
    localStorage.removeItem('user');
    localStorage.removeItem('authToken');
  };

  // בדיקה אם המשתמש מחובר
  const isAuthenticated = () => {
    return !!user;
  };

  const value = {
    user,
    login,
    logout,
    isAuthenticated,
    loading
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}