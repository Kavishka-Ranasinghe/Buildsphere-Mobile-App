const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const app = express();

const serviceAccount = require('../firebase/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'greeneats-9adc7'
});

// Enable CORS for requests from localhost:3000
app.use(cors({
  origin: 'http://localhost:3000'
}));

app.use(express.json());

// Test endpoint
app.get('/', (req, res) => {
  res.send('Firebase Admin SDK Server Running');
});

// Delete user endpoint
app.post('/deleteUser', async (req, res) => {
  const { uid } = req.body;
  if (!uid) {
    return res.status(400).send('UID is required');
  }

  try {
    await admin.auth().deleteUser(uid);
    res.status(200).send('User deleted successfully');
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).send('Error deleting user: ' + error.message);
  }
});

app.listen(5000, () => {
  console.log('Server running on port 5000');
});