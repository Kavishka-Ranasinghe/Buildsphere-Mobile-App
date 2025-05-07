# 🛠️ BuildSphere Admin Panel

This is the **Admin Web Panel** for the BuildSphere project. It allows an admin to log in, view user profiles, and securely delete users from Firebase Authentication and Firestore using the Firebase Admin SDK.

---

## 📁 Project Structure
admin_panel_web/
├── client/ # React frontend
└── server/ # Node backend with Firebase Admin SDK

1. Install Dependencies
    # go to admin_panel_web folder
    Install in both frontend and backend folders:

        1) cd client
        npm install

        2) cd ../server
        npm install

2. Start the Application
    Start both frontend and backend:
    1)
        # In one terminal
        cd client
        npm start

    2)
        # In another terminal
        cd server
        node index.js

start application locally check
    React app: http://localhost:3000
    Node backend: http://localhost:5000 (default, changeable)