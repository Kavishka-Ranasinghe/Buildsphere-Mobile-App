// src/LoginPage.js
import React, { useState } from 'react';
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from './firebase';

function LoginPage({ onLoginSuccess }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleLogin = async (e) => {
    e.preventDefault();
    setError("");

    try {
      await signInWithEmailAndPassword(auth, email, password);
      onLoginSuccess(); // navigate to dashboard
    } catch (err) {
      setError("Login failed: " + err.message);
    }
  };

  return (
    <div style={{ padding: "50px", textAlign: "center" }}>
      <h2>Admin Login</h2>
      {error && <p style={{ color: "red" }}>{error}</p>}
      <form onSubmit={handleLogin}>
        <input
          type="email"
          placeholder="Admin Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        /><br/><br/>
        <input
          type="password"
          placeholder="Admin Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        /><br/><br/>
        <button type="submit">Login</button>
      </form>
    </div>
  );
}

export default LoginPage;
