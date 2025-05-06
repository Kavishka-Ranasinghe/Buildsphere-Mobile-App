// src/components/Dashboard.js
import React, { useEffect, useState } from 'react';
import { db } from './firebase';
import { collection, getDocs } from 'firebase/firestore';
import UserTile from './UserTile';

function Dashboard() {
  const [users, setUsers] = useState([]);
  
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

  const roles = ['Client', 'Engineer', 'Planner', 'Hardware Shop Owner'];

  return (
    <div style={{ padding: '20px' }}>
      <h1>👋 Admin Dashboard</h1>
      {roles.map(role => (
        <div key={role}>
          <h2>{role}s</h2>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '15px' }}>
            {users.filter(user => user.role === role).map(user => (
              <UserTile key={user.id} user={user} />
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

export default Dashboard;
