// src/components/UserDetail.js
import React, { useEffect, useState } from 'react';
import { db } from './firebase';
import { doc, getDoc, deleteDoc } from 'firebase/firestore';
import { useParams, useNavigate } from 'react-router-dom';

function UserDetail() {
  const { uid } = useParams();
  const navigate = useNavigate();
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetchUser();
  }, []);

  const fetchUser = async () => {
    const userDoc = await getDoc(doc(db, 'users', uid));
    if (userDoc.exists()) {
      setUser({ id: userDoc.id, ...userDoc.data() });
    }
  };

  const handleDelete = async () => {
    if (window.confirm("Delete this user?")) {
      try {
        await deleteDoc(doc(db, 'users', uid));
        alert("Deleted from Firestore!");
        navigate('/dashboard');
      } catch (e) {
        alert("Error deleting user: " + e.message);
      }
    }
  };

  if (!user) return <div>Loading user...</div>;

  return (
    <div style={{ padding: '20px' }}>
      <h1>{user.name}</h1>
      <img
        src={user.profileImage || 'https://via.placeholder.com/150'}
        alt="profile"
        style={{ width: 150, height: 150, borderRadius: '50%' }}
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
