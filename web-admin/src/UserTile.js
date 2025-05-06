// src/components/UserTile.js
import React from 'react';
import { useNavigate } from 'react-router-dom';

function UserTile({ user }) {
  const navigate = useNavigate();

  const placeholder = 'https://via.placeholder.com/100x100.png?text=No+Image';

  return (
    <div
      onClick={() => navigate(`/user/${user.id}`)}
      style={{
        width: 150,
        padding: 10,
        border: '1px solid gray',
        borderRadius: 10,
        textAlign: 'center',
        cursor: 'pointer',
        backgroundColor: 'white'
      }}
    >
      <img
        src={user.profileImage || placeholder}
        alt="profile"
        style={{ width: 100, height: 100, borderRadius: '50%' }}
      />
      <h4>{user.name}</h4>
    </div>
  );
}

export default UserTile;
