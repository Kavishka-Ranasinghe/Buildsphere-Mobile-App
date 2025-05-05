// src/Dashboard.js
import React, { useEffect, useState } from 'react';
import { db } from './firebase';
import { collection, getDocs } from 'firebase/firestore';
import UserTile from './UserTile';

function Dashboard() {
  const [users, setUsers] = useState([]);
  const [selectedRole, setSelectedRole] = useState('All Users');

  const roles = ['All Users', 'Client', 'Engineer', 'Planner', 'Hardware Shop Owner'];

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    const usersCollection = collection(db, 'users');
    const snapshot = await getDocs(usersCollection);
    const userList = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    setUsers(userList);
  };

  const getUserCount = (role) => {
    if (role === 'All Users') return users.length;
    return users.filter(user => user.role === role).length;
  };

  const filteredUsers = selectedRole === 'All Users'
    ? users
    : users.filter(user => user.role === selectedRole);

  return (
    <div style={{ padding: '20px' }}>
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
        {filteredUsers.map(user => (
          <UserTile key={user.id} user={user} />
        ))}
      </div>
    </div>
  );
}

export default Dashboard;
