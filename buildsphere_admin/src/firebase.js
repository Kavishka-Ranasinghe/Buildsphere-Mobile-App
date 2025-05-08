import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

// Your web app's Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyDRIszAwvGbWhkgXBkj6qq35YfpPbChUUs",
    authDomain: "greeneats-9adc7.firebaseapp.com",
    projectId: "greeneats-9adc7",
    storageBucket: "greeneats-9adc7.appspot.com",
    messagingSenderId: "985031298248",
    appId: "1:985031298248:web:10105dbc369a9224ff69fd"
  };
  

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
const auth = getAuth(app);
const db = getFirestore(app);

// Export the services for use in your app
export { auth, db };