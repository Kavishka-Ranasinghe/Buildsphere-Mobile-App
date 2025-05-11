import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { db } from '../firebase';
import { doc, getDoc, deleteDoc } from 'firebase/firestore';
import axios from 'axios';

// Define styles outside the component
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

const contentStyle = {
  position: 'relative',
  zIndex: 2,
  backgroundColor: 'rgba(255, 255, 255, 0.1)',
  backdropFilter: 'blur(15px)',
  borderRadius: '20px',
  padding: '30px',
  maxWidth: '600px',
  width: '100%',
  boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)',
  border: '1px solid rgba(255, 255, 255, 0.2)',
  textAlign: 'center',
  animation: 'fadeIn 0.5s ease forwards',
};

const titleStyle = {
  fontFamily: "'Inter', sans-serif",
  fontSize: '2rem',
  fontWeight: '700',
  color: '#1a1a1a',
  marginBottom: '20px',
};

const imageStyle = {
  width: '150px',
  height: '150px',
  borderRadius: '50%',
  objectFit: 'cover',
  marginBottom: '20px',
  border: '3px solid #007bff',
  boxShadow: '0 4px 15px rgba(0, 123, 255, 0.2)',
};

const textStyle = {
  fontFamily: "'Inter', sans-serif",
  fontSize: '1.1rem',
  color: '#333333',
  margin: '10px 0',
  backgroundColor: 'rgba(255, 255, 255, 0.7)',
  padding: '8px 16px',
  borderRadius: '8px',
};

const buttonStyle = {
  padding: '12px 24px',
  background: 'linear-gradient(135deg, #ff4d4d 0%, #cc0000 100%)',
  color: '#ffffff',
  border: 'none',
  borderRadius: '12px',
  cursor: 'pointer',
  fontFamily: "'Inter', sans-serif",
  fontSize: '1rem',
  fontWeight: '600',
  transition: 'all 0.3s ease',
  boxShadow: '0 4px 15px rgba(255, 77, 77, 0.3)',
  marginTop: '20px',
  '&:hover': {
    transform: 'translateY(-2px)',
    boxShadow: '0 6px 20px rgba(255, 77, 77, 0.5)',
    background: 'linear-gradient(135deg, #cc0000 0%, #990000 100%)',
  },
};

const loadingStyle = {
  fontFamily: "'Inter', sans-serif",
  fontSize: '1.2rem',
  color: '#ffffff',
  textAlign: 'center',
  backgroundColor: 'rgba(0, 0, 0, 0.5)',
  padding: '20px',
  borderRadius: '10px',
};

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
      let authSuccess = false;

      try {
        // Attempt to delete from Firebase Authentication
        await axios.post('http://localhost:5000/deleteUser', { uid });
        authSuccess = true;
      } catch (authError) {
        console.warn('Authentication deletion failed or user not found:', authError.message);
        // Continue even if Authentication fails
      }

      try {
        // Delete from Firestore using the same uid
        await deleteDoc(doc(db, 'users', uid));
        const message = authSuccess
          ? '✅ User deleted from both Authentication and Firestore successfully!'
          : '✅ User deleted from Firestore successfully! (Authentication already removed or failed)';
        alert(message);
        navigate('/dashboard');
      } catch (firestoreError) {
        alert('❌ Error deleting user from Firestore: ' + firestoreError.message);
      }
    }
  };

  if (!user) {
    return (
      <div style={containerStyle}>
        <div style={loadingStyle}>Loading user...</div>
      </div>
    );
  }

  return (
    <div style={containerStyle}>
      {/* Overlay for the blurred background */}
      <div style={blurOverlayStyle} />

      {/* Content layer */}
      <div style={contentStyle}>
        <h1 style={titleStyle}>{user.name || 'No Name'}</h1>
        <img
          src={user.profileImage || placeholder}
          alt="profile"
          style={imageStyle}
        />
        <p style={textStyle}><strong>Email:</strong> {user.email || 'No Email'}</p>
        <p style={textStyle}><strong>Role:</strong> {user.role || 'N/A'}</p>
        <p style={textStyle}><strong>District:</strong> {user.district || 'N/A'}</p>
        <p style={textStyle}><strong>City:</strong> {user.city || 'N/A'}</p>
        <p style={textStyle}><strong>UID:</strong> {user.id}</p>
        <button
          style={buttonStyle}
          onClick={handleDelete}
        >
          Delete User
        </button>
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
            box-shadow: 0 6px 20px rgba(255, 77, 77, 0.5);
          }
        `}
      </style>
    </div>
  );
}

export default UserDetail;