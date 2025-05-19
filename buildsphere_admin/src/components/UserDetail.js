import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { db } from '../firebase';
import { doc, getDoc, deleteDoc, collection, query, where, getDocs } from 'firebase/firestore';
import axios from 'axios';

const COMETCHAT_APP_ID = '272345917d37d43c';
const COMETCHAT_API_KEY = '409c0d63bee3024db427268ecb10b83f8692d77b'; // Updated to REST API Key
const COMETCHAT_REGION = 'in';
const COMETCHAT_BASE_URL = `https://${COMETCHAT_APP_ID}.api-${COMETCHAT_REGION}.cometchat.io/v3/users`;

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
      let cometChatSuccess = false;
      let productsSuccess = false;

      // Check if user has a CometChat account based on role
      const hasCometChatAccount = user && ['client', 'engineer', 'planner'].includes(user.role.toLowerCase());
      const isHardwareShopOwner = user && user.role.toLowerCase() === 'hardware shop owner';

      try {
        // Delete from CometChat if the user has a CometChat account
        if (hasCometChatAccount) {
          await axios.delete(`${COMETCHAT_BASE_URL}/${uid}`, {
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
              'apikey': COMETCHAT_API_KEY,
            },
            data: { permanent: true },
          });
          cometChatSuccess = true;
        }
      } catch (cometChatError) {
        console.warn('CometChat deletion failed:', cometChatError.message);
        // Continue even if CometChat fails
      }

      try {
        // Delete from Firebase Authentication
        await axios.post('http://localhost:5000/deleteUser', { uid });
        authSuccess = true;
      } catch (authError) {
        console.warn('Authentication deletion failed:', authError.message);
        // Continue even if Authentication fails
      }

      try {
        // Delete associated products if the user is a Hardware shop owner
        if (isHardwareShopOwner) {
          const productsQuery = query(
            collection(db, 'products'),
            where('ownerId', '==', uid)
          );
          const productDocs = await getDocs(productsQuery);
          const deletePromises = productDocs.docs.map(doc => deleteDoc(doc.ref));
          await Promise.all(deletePromises);
          productsSuccess = true;
        }
      } catch (productsError) {
        console.warn('Products deletion failed:', productsError.message);
        // Continue even if products deletion fails
      }

      try {
        // Delete from Firestore (users collection)
        await deleteDoc(doc(db, 'users', uid));
        // Construct success message based on what succeeded
        let message = '✅ User deleted from Firestore successfully!';
        if (authSuccess) message += ' (Authentication also deleted)';
        if (hasCometChatAccount && cometChatSuccess) message += ' (CometChat also deleted)';
        else if (hasCometChatAccount && !cometChatSuccess) message += ' (CometChat deletion failed)';
        if (isHardwareShopOwner && productsSuccess) message += ' (Products also deleted)';
        else if (isHardwareShopOwner && !productsSuccess) message += ' (Products deletion failed)';
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
        <img src={user.profileImage || placeholder} alt="profile" style={imageStyle} />
        <p style={textStyle}><strong>Email:</strong> {user.email || 'No Email'}</p>
        <p style={textStyle}><strong>Name:</strong> {user.name || 'No Name'}</p>
        <p style={textStyle}><strong>Role:</strong> {user.role || 'N/A'}</p>
        <p style={textStyle}><strong>District:</strong> {user.district || 'N/A'}</p>
        <p style={textStyle}><strong>City:</strong> {user.city || 'N/A'}</p>
        <p style={textStyle}><strong>UID:</strong> {user.id}</p>
        <button style={buttonStyle} onClick={handleDelete}>Delete User</button>
      </div>
      {/* CSS Animation */}
      <style>{`
        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        button:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(255, 77, 77, 0.5); }
      `}</style>
    </div>
  );
}

export default UserDetail;