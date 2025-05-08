const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const app = express();

const serviceAccount = require('../firebase/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'greeneats-9adc7'
});

app.use(cors({
  origin: 'http://localhost:3000'
}));

app.use(express.json());

app.get('/', (req, res) => {
  res.send('Firebase Admin SDK Server Running');
});

app.post('/deleteUser', async (req, res) => {
  const { uid } = req.body;
  if (!uid) {
    return res.status(400).send('UID is required');
  }

  try {
    await admin.auth().deleteUser(uid);
    res.status(200).send('User deleted successfully');
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.warn('User not found in Authentication:', uid);
      res.status(200).send('User not found in Authentication, skipping deletion');
    } else {
      console.error('Error deleting user:', error.message);
      res.status(500).send(`Error deleting user: ${error.message}`);
    }
  }
});

app.listen(5000, () => {
  console.log('Server running on port 5000');
});

process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});