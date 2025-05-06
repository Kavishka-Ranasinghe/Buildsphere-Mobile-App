// src/components/UserDetail.js
import React, { useEffect, useState } from 'react';
import { db } from './firebase';
import { doc, getDoc } from 'firebase/firestore';
import { getFunctions, httpsCallable } from 'firebase/functions';
import { app } from './firebase';
import { useParams, useNavigate } from 'react-router-dom';

function UserDetail() {
  const { uid } = useParams(); // param from URL
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const functions = getFunctions(app); // initialize functions

  const placeholder = '/profile_avatar.png';

  // ✅ fetch user data by document ID
  useEffect(() => {
    const fetchUser = async () => {
      const userDoc = await getDoc(doc(db, 'users', uid));
      if (userDoc.exists()) {
        setUser({
          id: userDoc.id,              // 👈 this is the document ID (== auth UID)
          ...userDoc.data(),           // other fields
        });
      }
    };
    fetchUser();
  }, [uid]); // ✅ added uid as dependency

  const handleDelete = async () => {
    if (window.confirm("Delete this user?")) {
      try {
        const deleteUserData = httpsCallable(functions, 'deleteUserData');
        console.log("🔥 Sending uid to backend:", user.id); // debug log
        await deleteUserData({ uid: user.id });  // 👈 send correct param
        alert("✅ User deleted from Firebase!");
        navigate('/dashboard');
      } catch (error) {
        alert("❌ Error deleting user: " + error.message);
      }
    }
  };

  if (!user) return <div>Loading user...</div>;

  return (
    <div style={{ padding: '20px' }}>
      <h1>{user.name}</h1>
      <img
        src={user.profileImage || placeholder}
        alt="profile"
        style={{ width: 150, height: 150, borderRadius: '50%', objectFit: 'cover' }}
      />
      <p>Email: {user.email}</p>
      <p>Role: {user.role}</p>
      <p>District: {user.district || 'N/A'}</p>
      <p>City: {user.city || 'N/A'}</p>
      <p>UID: {user.id}</p>

      <button
        style={{ backgroundColor: 'red', color: 'white', padding: '10px 20px' }}
        onClick={handleDelete}
      >
        Delete User
      </button>
    </div>
  );
}

export default UserDetail;
