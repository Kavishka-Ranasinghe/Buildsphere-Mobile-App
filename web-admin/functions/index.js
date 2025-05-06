const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.deleteUserData = functions.https.onCall(async (data, context) => {
  const uid = data.uid;
  console.log("🔥 UID received:", uid);

  try {
    const userDocRef = admin.firestore().collection('users').doc(uid);

    // ✅ delete document directly
    await userDocRef.delete();

    // ✅ delete auth user
    await admin.auth().deleteUser(uid);

    // ✅ delete storage files
    const bucket = admin.storage().bucket();
    await bucket.deleteFiles({ prefix: `profile_images/${uid}/` });

    console.log(`✅ Fully deleted user: ${uid}`);
    return { message: `User ${uid} deleted successfully.` };
  } catch (error) {
    console.error('❌ Error deleting user:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
