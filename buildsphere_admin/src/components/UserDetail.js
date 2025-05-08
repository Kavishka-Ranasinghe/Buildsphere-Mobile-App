import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { db } from '../firebase';
import { doc, getDoc, deleteDoc } from 'firebase/firestore';
import axios from 'axios';

function UserDetail() {
  const { uid } = useParams();
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const placeholder = '/profile_avatar.png';

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const userDoc = await getDoc(doc(db, 'users', uid));
        if (userDoc.exists()) {
          setUser({
            id: userDoc.id,
            ...userDoc.data()
          });
        } else {
          console.error('User not found');
        }
      } catch (err) {
        console.error('Error fetching user:', err);
      }
    };
    fetchUser();
  }, [uid]);

  const handleDelete = async () => {
    if (window.confirm('Delete this user?')) {
      try {
        // Try to delete from Firebase Authentication
        await axios.post('http://localhost:5000/deleteUser', { uid });
      } catch (authError) {
        console.warn('Authentication deletion failed:', authError.message);
        // Continue to Firestore deletion even if Authentication fails
      }

      try {
        // Delete from Firestore
        await deleteDoc(doc(db, 'users', uid));
        alert('✅ User deleted from Firestore successfully!');
        navigate('/dashboard');
      } catch (firestoreError) {
        alert('❌ Error deleting user from Firestore: ' + firestoreError.message);
      }
    }
  };

  if (!user) return <div>Loading user...</div>;

  return (
    <div style={{ padding: '20px' }}>
      <h1>{user.name || 'No Name'}</h1>
      <img
        src={user.profileImage || placeholder}
        alt="profile"
        style={{ width: 150, height: 150, borderRadius: '50%', objectFit: 'cover', marginBottom: '20px' }}
      />
      <p>Email: {user.email || 'No Email'}</p>
      <p>Role: {user.role || 'N/A'}</p>
      <p>District: {user.district || 'N/A'}</p>
      <p>City: {user.city || 'N/A'}</p>
      <p>UID: {user.id}</p>
      <button
        style={{ backgroundColor: 'red', color: 'white', padding: '10px 20px', marginTop: '20px' }}
        onClick={handleDelete}
      >
        Delete User
      </button>
    </div>
  );
}

export default UserDetail;