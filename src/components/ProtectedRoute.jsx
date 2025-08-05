import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export default function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    // אפשר להוסיף כאן קומפוננטת טעינה יפה יותר
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-lg">טוען...</div>
      </div>
    );
  }

  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }

  return children;
}