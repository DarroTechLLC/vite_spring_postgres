import { LoginForm } from '@/features/auth/components/LoginForm';
import { RegisterForm } from '@/features/auth/components/RegisterForm';
import { authService } from '@/features/auth/services/authService';
import { View1 } from '@/features/dashboard/components/View1';
import { View2 } from '@/features/dashboard/components/View2';
import { View3 } from '@/features/dashboard/components/View3';
import { WelcomePage } from '@/features/dashboard/components/WelcomePage';
import { Layout } from '@/shared/components/Layout';
import { ProtectedRoute } from '@/shared/components/ProtectedRoute';
import { useAuth } from '@/shared/hooks/useAuth';
import { useEffect } from 'react';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';

function App() {
  const { setUser } = useAuth();

  useEffect(() => {
    const user = authService.getCurrentUser();
    if (user) {
      setUser({ name: user.name, email: user.email });
    }
  }, [setUser]);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginForm />} />
        <Route path="/register" element={<RegisterForm />} />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Layout />
            </ProtectedRoute>
          }
        >
          <Route index element={<WelcomePage />} />
          <Route path="view1" element={<View1 />} />
          <Route path="view2" element={<View2 />} />
          <Route path="view3" element={<View3 />} />
        </Route>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
