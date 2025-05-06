const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.deleteUserData = functions.https.onCall(async (data, context) => {
  const uid = data.uid;
  try {
    // Delete Firestore user document
    await admin.firestore().collection('users').doc(uid).delete();

    // Delete Storage files
    const bucket = admin.storage().bucket();
    await bucket.deleteFiles({ prefix: `profile_images/${uid}/` });

    // Delete Firebase Auth user
    await admin.auth().deleteUser(uid);

    console.log(`✅ Deleted user ${uid}`);
    return { message: `User ${uid} deleted successfully.` };
  } catch (error) {
    console.error("❌ Error deleting user:", error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
