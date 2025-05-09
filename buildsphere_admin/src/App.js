import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { auth } from './firebase';
import { signOut } from 'firebase/auth';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import UserDetail from './components/UserDetail';

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Sign out on initial load to force login
    signOut(auth).then(() => {
      setUser(null);
      setLoading(false);
    }).catch((error) => {
      console.error('Error signing out:', error);
      setUser(null);
      setLoading(false);
    });

    // Set up auth state listener
    const unsubscribe = auth.onAuthStateChanged((user) => {
      console.log('Auth state changed:', user); // Debug log
      setUser(user);
      if (!loading) setLoading(false); // Ensure loading state is managed
    });

    return () => unsubscribe();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/dashboard"
          element={
            user ? <Dashboard /> : <Navigate to="/login" replace />
          }
        />
        <Route
          path="/"
          element={<Navigate to="/login" replace />}
        />
        <Route
          path="/user/:uid"
          element={
            user ? <UserDetail /> : <Navigate to="/login" replace />
          }
        />
        <Route path="*" element={<div>404 Not Found</div>} />
      </Routes>
    </Router>
  );
}

export default App;