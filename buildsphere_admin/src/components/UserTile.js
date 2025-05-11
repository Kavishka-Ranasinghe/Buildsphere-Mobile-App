import React from 'react';
import { Link } from 'react-router-dom';

function UserTile({ user }) {
  const placeholder = '/profile_avatar.png';

  // Define reusable styles
  const tileStyle = {
    backgroundColor: '#ffffff', // Solid white background
    borderRadius: '15px',
    padding: '20px',
    boxShadow: '0 4px 15px rgba(0, 0, 0, 0.1)',
    transition: 'transform 0.3s ease, box-shadow 0.3s ease',
    textAlign: 'center',
    '&:hover': {
      transform: 'translateY(-5px)',
      boxShadow: '0 8px 25px rgba(0, 0, 0, 0.2)',
    },
  };

  const imageStyle = {
    width: '100px',
    height: '100px',
    borderRadius: '50%',
    objectFit: 'cover',
    marginBottom: '15px',
    border: '2px solid #007bff', // Matching the dashboard's blue theme
  };

  const textStyle = {
    fontFamily: "'Inter', sans-serif",
    fontSize: '1rem',
    color: '#333333',
    margin: '5px 0',
  };

  const linkStyle = {
    display: 'inline-block',
    marginTop: '10px',
    padding: '8px 16px',
    background: 'linear-gradient(135deg, #007bff 0%, #0056b3 100%)',
    color: '#ffffff',
    textDecoration: 'none',
    borderRadius: '8px',
    fontFamily: "'Inter', sans-serif",
    fontWeight: '600',
    transition: 'background 0.3s ease',
    '&:hover': {
      background: 'linear-gradient(135deg, #0056b3 0%, #003d82 100%)',
    },
  };

  return (
    <div style={tileStyle}>
      <img
        src={user.profileImage || placeholder}
        alt="profile"
        style={imageStyle}
      />
      <p style={textStyle}><strong>Name:</strong> {user.name || 'No Name'}</p>
      <p style={textStyle}><strong>Email:</strong> {user.email || 'No Email'}</p>
      <p style={textStyle}><strong>Role:</strong> {user.role || 'N/A'}</p>
      <Link to={`/user/${user.id}`} style={linkStyle}>
        View Details
      </Link>
    </div>
  );
}

export default UserTile;