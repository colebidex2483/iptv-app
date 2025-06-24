// controllers/UserLicenseController.js

const admin = require('firebase-admin');
const db = admin.firestore();

// ==============================
// 1. User Activation with Code
// ==============================
// userLicenseController.js

exports.activateUserWithCode = async (req, res) => {
  const { code, deviceInfo } = req.body;

  try {
    // 🔍 Query by 'code' field instead of assuming it's the doc ID
    const codeQuery = await db.collection('activationCodes')
      .where('code', '==', code)
      .limit(1)
      .get();

    if (codeQuery.empty) {
      return res.status(400).json({ error: 'Invalid code' });
    }

    const codeDoc = codeQuery.docs[0];
    const codeRef = codeDoc.ref;
    const data = codeDoc.data();

    // ✅ Check if code is already used
    if (data.isUsed) {
      return res.status(400).json({ error: 'Code already used' });
    }

    // ✅ Check expiration
    if (data.expiresAt.toDate() < new Date()) {
      return res.status(400).json({ error: 'Code expired' });
    }

    // ✅ Create user
    const userId = `${deviceInfo.mac}-${Date.now()}`;
    const userData = {
      uid: userId,
      activationCode: code,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: data.expiresAt,
      deviceInfo,
    };

    // Save user
    await db.collection('users').doc(userId).set(userData);

    // Mark code as used
    await codeRef.update({
      isUsed: true,
      assignedTo: userId,
      usedAt: admin.firestore.FieldValue.serverTimestamp(),
      deviceInfo,
    });

    return res.status(200).json({ message: 'User activated', userId });

  } catch (err) {
    console.error('[Activate Error]', err);
    return res.status(500).json({ error: err.message });
  }
};


// ======================================
// 2. Middleware: Check License Expiry
// ======================================
exports.checkLicenseValidity = async (req, res, next) => {
  const userId = req.headers['x-user-id'];

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userDoc.data();
    if (!user.isActive) {
      return res.status(403).json({ error: 'License inactive' });
    }

    if (user.expiresAt.toDate() < new Date()) {
      await db.collection('users').doc(userId).update({ isActive: false });
      return res.status(403).json({ error: 'License expired' });
    }

    req.user = user;
    next();
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

// =======================================
// 3. Admin: Extend License Expiry
// =======================================
exports.extendLicense = async (req, res) => {
  const { userId, newExpiryDate } = req.body;

  try {
    await db.collection('users').doc(userId).update({
      expiresAt: admin.firestore.Timestamp.fromDate(new Date(newExpiryDate)),
      isActive: true,
    });

    return res.status(200).json({ message: 'License extended' });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

// =====================================
// 4. Admin: Revoke/Reset License
// =====================================
exports.revokeLicense = async (req, res) => {
  const { userId } = req.body;

  try {
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userDoc.data();
    const codeRef = db.collection('activationCodes').doc(user.activationCode);

    await userRef.update({ isActive: false });
    await codeRef.update({
      isUsed: false,
      assignedTo: null,
      deviceInfo: null,
      usedAt: null,
    });

    return res.status(200).json({ message: 'License revoked and code reset' });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

// =======================================
// 5. List Active Users
// =======================================
exports.listActiveUsers = async (req, res) => {
  try {
    const snapshot = await db.collection('users').where('isActive', '==', true).get();
    const users = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    return res.status(200).json(users);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

