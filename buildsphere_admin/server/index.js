const admin = require('firebase-admin');
const express = require('express');
const app = express();

const serviceAccount = require('../firebase/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'greeneats-9adc7'
});

app.use(express.json());

app.get('/', (req, res) => {
  res.send('Firebase Admin SDK Server Running');
});

app.listen(5000, () => {
  console.log('Server running on port 5000');
});