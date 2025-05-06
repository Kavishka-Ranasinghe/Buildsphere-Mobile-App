const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const { deleteUser } = require('firebase-admin/auth');
const { firestore } = require('firebase-admin');
const { deleteCollection, recursiveDelete } = require('firebase-tools');

admin.initializeApp();

exports.deleteUserData = functions.https.onCall(async (data, context) => {
  const uid = data.docId;  // ✅ match frontend key

  console.log("🔥 UID received:", uid); // 👈 add this log
  try {
    const userDocRef = admin.firestore().collection('users').doc(uid);

    // ✅ delete subcollections recursively
    await require('firebase-tools').firestore
      .delete(userDocRef.path, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
      });

    // ✅ delete user from Firebase Auth
    await admin.auth().deleteUser(uid);

    // ✅ optionally delete storage files
    const bucket = admin.storage().bucket();
    await bucket.deleteFiles({ prefix: `profile_images/${uid}/` });

    console.log(`✅ Fully deleted user: ${uid}`);
    return { message: `User ${uid} deleted successfully.` };
  } catch (error) {
    console.error('❌ Error deleting user:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
