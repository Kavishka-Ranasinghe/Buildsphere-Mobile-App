import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDRIszAwvGbWhkgXBkj6qq35YfpPbChUUs",
  authDomain: "greeneats-9adc7.firebaseapp.com",
  projectId: "greeneats-9adc7",
  storageBucket: "greeneats-9adc7.appspot.com",
  messagingSenderId: "985031298248",
  appId: "1:985031298248:web:870d9fb73f583a4aff69fd"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export { app }; 