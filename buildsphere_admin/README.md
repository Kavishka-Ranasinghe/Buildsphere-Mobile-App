# BuildSphere Admin Panel

This is the admin panel for the BuildSphere app, built with React and Firebase. It allows the admin to log in, view user profiles, delete users, and update their own profile.

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Node.js**: Version 18 or higher (check with `node -v`).
- **npm**: Comes with Node.js (check with `npm -v`).
- **Visual Studio Code**: Recommended editor with ESLint and Prettier extensions.

## Setup Instructions

Follow these steps to set up and run the project on your local machine after cloning the repository.

### 1. Clone the Repository

- Clone the repository to your local machine:

- Navigate to the `buildsphere_admin` folder: in terminal
  cd buildsphere/buildsphere_admin

### 2. Install Frontend Dependencies

- In the `buildsphere_admin` folder, install the dependencies:
  npm install

### 3. Set Up Firebase Configuration

- Obtain the Firebase configuration object from the Firebase Console (`greeneats-9adc7` project):
- Go to "Project settings" > "Your apps" > Add a web app (if not already added).
- Copy the `firebaseConfig` object.
- Open `src/firebase.js` and replace the placeholder `firebaseConfig` with your config object.
- Obtain the service account key from the Firebase Console:
- Go to "Project settings" > "Service Accounts" > "Generate new private key".
- Save the downloaded JSON file as `firebase/serviceAccountKey.json` in the `buildsphere_admin` folder.
- **Note**: This file is ignored by `.gitignore` and should not be shared publicly.

### 4. Install Backend Dependencies

- Navigate to the `server` folder:
  cd server

- Install the backend dependencies:
  npm install

### 5. Run the Application

- **Run the Frontend**:
- From the `buildsphere_admin` folder:
  npm start

  - This will start the React app at `http://localhost:3000`.

- **Run the Backend**:
- In a separate terminal, from the `buildsphere_admin/server` folder:
  node index.js

- This will start the Firebase Admin SDK server at `http://localhost:5000`.

### 6. Access the Admin Panel

- Open your browser and go to `http://localhost:3000` to view the admin panel.
- The backend server at `http://localhost:5000` handles secure operations like user deletion.

## Project Structure

- `src/`: React source code for the frontend.
- `firebase/`: Firebase configuration and service account key.
- `server/`: Node.js backend with Firebase Admin SDK.

## Notes

- Ensure you have the correct Firebase configuration and service account key.
- The project uses React 16.13.1 and react-scripts 3.4.1, which have known vulnerabilities. Update these before deploying to production.
