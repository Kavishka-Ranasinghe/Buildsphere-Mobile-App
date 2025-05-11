import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth } from '../firebase';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { Button, Form, Container, Alert } from 'react-bootstrap';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError(null); // Clear previous errors
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      // Wait for auth state to update
      await new Promise((resolve) => setTimeout(resolve, 500)); // Small delay to ensure state sync
      if (userCredential.user) {
        navigate('/dashboard');
      } else {
        setError('Login failed, user not authenticated.');
      }
    } catch (err) {
      setError(err.message);
    }
  };

  // Define reusable styles
  const containerStyle = {
    minHeight: '100vh',
    backgroundImage: 'url(/Dashboard.jpg)',
    backgroundSize: 'cover',
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    position: 'relative',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    padding: '40px 20px',
  };

  const blurOverlayStyle = {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    backgroundImage: 'url(/Dashboard.jpg)',
    backgroundSize: 'cover',
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    filter: 'blur(10px)',
    zIndex: 1,
  };

  const formContainerStyle = {
    position: 'relative',
    zIndex: 2,
    backgroundColor: 'rgba(255, 255, 255, 0.7)', // Adjusted: Increased opacity for a whiter look
    backdropFilter: 'blur(15px)',
    borderRadius: '20px',
    padding: '30px',
    maxWidth: '400px',
    width: '100%',
    boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)',
    border: '1px solid rgba(255, 255, 255, 0.2)',
    animation: 'fadeIn 0.5s ease forwards',
  };

  const titleStyle = {
    fontFamily: "'Inter', sans-serif",
    fontSize: '2rem',
    fontWeight: '700',
    color: '#1a1a1a',
    marginBottom: '20px',
    textAlign: 'center',
  };

  const alertStyle = {
    marginBottom: '20px',
    borderRadius: '8px',
  };

  const buttonStyle = {
    width: '100%',
    padding: '12px',
    background: 'linear-gradient(135deg, #007bff 0%, #0056b3 100%)',
    color: '#ffffff',
    border: 'none',
    borderRadius: '12px',
    fontFamily: "'Inter', sans-serif",
    fontSize: '1rem',
    fontWeight: '600',
    transition: 'all 0.3s ease',
    boxShadow: '0 4px 15px rgba(0, 123, 255, 0.3)',
    '&:hover': {
      transform: 'translateY(-2px)',
      boxShadow: '0 6px 20px rgba(0, 0, 0, 0.15)',
      background: 'linear-gradient(135deg, #0056b3 0%, #003d82 100%)',
    },
  };

  return (
    <div style={containerStyle}>
      {/* Overlay for the blurred background */}
      <div style={blurOverlayStyle} />

      {/* Form container */}
      <div style={formContainerStyle}>
        <h2 style={titleStyle}>Admin Login</h2>
        {error && <Alert variant="danger" style={alertStyle}>{error}</Alert>}
        <Form onSubmit={handleLogin}>
          <Form.Group controlId="email" className="mb-3">
            <Form.Label>Email</Form.Label>
            <Form.Control
              type="email"
              placeholder="Enter email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </Form.Group>

          <Form.Group controlId="password" className="mb-3">
            <Form.Label>Password</Form.Label>
            <Form.Control
              type="password"
              placeholder="Enter password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </Form.Group>

          <Button variant="primary" style={buttonStyle} type="submit">
            Login
          </Button>
        </Form>
      </div>

      {/* CSS Animation */}
      <style>
        {`
          @keyframes fadeIn {
            from {
              opacity: 0;
              transform: translateY(20px);
            }
            to {
              opacity: 1;
              transform: translateY(0);
            }
          }

          button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
          }
        `}
      </style>
    </div>
  );
}

export default Login;