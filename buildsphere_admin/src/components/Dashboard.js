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
        const usersList = usersSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
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

  return (
    <div
      style={{
        padding: '20px',
        minHeight: '100vh', // Ensure the background covers the full viewport height
        backgroundImage: 'url(/dashboard.png)', // Reference the image from the public folder
        backgroundSize: 'cover', // Cover the entire area
        backgroundPosition: 'center', // Center the image
        backgroundRepeat: 'no-repeat', // Prevent tiling
        position: 'relative', // For layering the content above the background
      }}
    >
      {/* Overlay for the blurred background */}
      <div
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          backgroundImage: 'url(/Dashboard.jpg)', // Same image for the blur layer
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          backgroundRepeat: 'no-repeat',
          filter: 'blur(8px)', // Apply blur effect
          zIndex: 1, // Behind the content
        }}
      />
      {/* Content layer */}
      <div
        style={{
          position: 'relative',
          zIndex: 2, // Above the blurred background
          backgroundColor: 'rgba(255, 255, 255, 0.8)', // Semi-transparent white background for readability
          borderRadius: '10px',
          padding: '20px',
        }}
      >
        <h1>👋 Admin Dashboard</h1>

        {/* TOP NAVIGATION */}
        <div style={{ display: 'flex', gap: '15px', marginBottom: '20px' }}>
          {roles.map(role => (
            <button
              key={role}
              onClick={() => setSelectedRole(role)}
              style={{
                padding: '10px 20px',
                backgroundColor: selectedRole === role ? '#007bff' : '#f0f0f0',
                color: selectedRole === role ? 'white' : 'black',
                border: 'none',
                borderRadius: '5px',
                cursor: 'pointer'
              }}
            >
              {role} ({getUserCount(role)})
            </button>
          ))}
        </div>

        {/* USER LIST */}
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '15px' }}>
          {filteredUsers.length > 0 ? (
            filteredUsers.map(user => (
              <UserTile key={user.id} user={user} />
            ))
          ) : (
            <p>No users found.</p>
          )}
        </div>
      </div>
    </div>
  );
}

export default Dashboard;