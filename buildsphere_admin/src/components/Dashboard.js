import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, getDocs } from 'firebase/firestore';
import UserTile from './UserTile';

function Dashboard() {
  const [users, setUsers] = useState([]);
  const [selectedRole, setSelectedRole] = useState('All Users');
  const roles = ['All Users', 'Client', 'Engineer', 'Planner', 'Hardware Shop Owner'];

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const usersCollection = collection(db, 'users');
        const usersSnapshot = await getDocs(usersCollection);
        const usersList = usersSnapshot.docs.map(doc => {
          const userData = doc.data();
          console.log('Raw user data:', { id: doc.id, ...userData }); // Debug raw data
          // Check if the user is a Hardware Shop Owner (case-insensitive)
          if (userData.role?.toLowerCase() === 'hardware shop owner') {
            const mappedUser = {
              id: doc.id,
              ...userData,
              name: userData.shopName+' shop' || 'No Shop Name', // Map shopName to name
            };
            console.log('Mapped Hardware Shop Owner:', mappedUser); // Debug mapped data
            return mappedUser;
          }
          // For other roles, use the data as-is
          const mappedUser = {
            id: doc.id,
            ...userData,
          };
          console.log('Mapped other role:', mappedUser); // Debug mapped data
          return mappedUser;
        });
        setUsers(usersList);
      } catch (err) {
        console.error('Error fetching users:', err);
      }
    };

    // Initial fetch
    fetchUsers();

    // Set interval to refresh every 2 seconds
    const intervalId = setInterval(fetchUsers, 2000);

    // Cleanup interval on unmount
    return () => clearInterval(intervalId);
  }, []);

  const getUserCount = (role) => {
    if (role === 'All Users') return users.length;
    return users.filter(user => user.role === role).length;
  };

  const filteredUsers = selectedRole === 'All Users'
    ? users
    : users.filter(user => user.role === selectedRole);

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

  const contentStyle = {
    position: 'relative',
    zIndex: 2,
    backgroundColor: 'rgba(255, 255, 255, 0.1)', // Glassmorphism effect
    backdropFilter: 'blur(15px)', // Additional glass effect
    borderRadius: '20px',
    padding: '30px',
    maxWidth: '1200px',
    width: '100%',
    boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)',
    border: '1px solid rgba(255, 255, 255, 0.2)',
  };

  const titleStyle = {
    fontFamily: "'Inter', sans-serif",
    fontSize: '2.5rem',
    fontWeight: '700',
    color: '#1a1a1a',
    marginBottom: '30px',
    textAlign: 'center',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '10px',
  };

  const navStyle = {
    display: 'flex',
    justifyContent: 'center',
    gap: '15px',
    marginBottom: '30px',
    flexWrap: 'wrap',
  };

  const buttonStyle = (isSelected) => ({
    padding: '12px 24px',
    background: isSelected
      ? 'linear-gradient(135deg, #007bff 0%, #0056b3 100%)'
      : 'rgba(255, 255, 255, 0.2)',
    color: isSelected ? '#ffffff' : '#333333',
    border: 'none',
    borderRadius: '12px',
    cursor: 'pointer',
    fontFamily: "'Inter', sans-serif",
    fontSize: '1rem',
    fontWeight: '600',
    transition: 'all 0.3s ease',
    boxShadow: isSelected ? '0 4px 15px rgba(0, 123, 255, 0.3)' : 'none',
    '&:hover': {
      transform: 'translateY(-2px)',
      boxShadow: '0 6px 20px rgba(0, 0, 0, 0.15)',
      background: isSelected
        ? 'linear-gradient(135deg, #0056b3 0%, #003d82 100%)'
        : 'rgba(255, 255, 255, 0.3)',
    },
  });

  const userListStyle = {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))',
    gap: '20px',
  };

  const noUsersStyle = {
    fontFamily: "'Inter', sans-serif",
    fontSize: '1.2rem',
    color: '#666666',
    textAlign: 'center',
    padding: '20px',
  };

  return (
    <div style={containerStyle}>
      {/* Overlay for the blurred background */}
      <div style={blurOverlayStyle} />

      {/* Content layer */}
      <div style={contentStyle}>
        <h1 style={titleStyle}>
         Buildsphere Admin Dashboard
        </h1>

        {/* TOP NAVIGATION */}
        <div style={navStyle}>
          {roles.map(role => (
            <button
              key={role}
              onClick={() => setSelectedRole(role)}
              style={buttonStyle(selectedRole === role)}
            >
              {role} ({getUserCount(role)})
            </button>
          ))}
        </div>

        {/* USER LIST */}
        <div style={userListStyle}>
          {filteredUsers.length > 0 ? (
            filteredUsers.map(user => (
              <div
                key={user.id}
                style={{
                  opacity: 0,
                  animation: 'fadeIn 0.5s ease forwards',
                }}
              >
                <UserTile user={user} />
              </div>
            ))
          ) : (
            <p style={noUsersStyle}>No users found.</p>
          )}
        </div>
      </div>

      {/* CSS Animation for User Tiles */}
      <style>
        {`
          @keyframes fadeIn {
            from {
              opacity: 0;
              transform: translateY(10px);
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

export default Dashboard;