import React from 'react';
import { Link } from 'react-router-dom';

function UserTile({ user }) {
  const placeholder = '/profile_avatar.png';

  return (
    <div style={{ padding: '10px', border: '1px solid #ddd', borderRadius: '5px', width: '200px' }}>
      <img
        src={user.profileImage || placeholder}
        alt="profile"
        style={{ width: 100, height: 100, borderRadius: '50%', objectFit: 'cover', display: 'block', margin: '0 auto' }}
      />
      <h3 style={{ fontSize: '1.2em', margin: '10px 0' }}>{user.name || 'No Name'}</h3>
      <p style={{ margin: '5px 0' }}>Email: {user.email || 'No Email'}</p>
      <p style={{ margin: '5px 0' }}>Role: {user.role || 'N/A'}</p>
      <Link
        to={`/user/${user.id}`}
        style={{ display: 'block', textAlign: 'center', marginTop: '10px', color: '#007bff', textDecoration: 'none' }}
      >
        View Details
      </Link>
    </div>
  );
}

export default UserTile;