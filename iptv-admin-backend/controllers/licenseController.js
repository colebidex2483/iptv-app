// controllers/licenseController.js
const db = require('../services/firestoreService');

// ✅ 1. Renew license by Firestore document ID (deviceId)
exports.renewLicense = async (req, res) => {
  try {
    const { deviceId, extensionMonths = 1 } = req.body;
    if (!deviceId) return res.status(400).json({ message: 'deviceId is required' });

    const userRef = db.collection('users').doc(deviceId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) return res.status(404).json({ message: 'User not found' });

    const userData = userDoc.data();

    if (userData.status && userData.status !== 'active') {
      return res.status(400).json({ message: 'Cannot renew inactive license' });
    }

    let currentExpiry = userData.expiresAt ? new Date(userData.expiresAt) : new Date();
    currentExpiry.setMonth(currentExpiry.getMonth() + extensionMonths);

    await userRef.update({
      expiresAt: currentExpiry.toISOString(),
      status: 'active',
      activated: true,
    });

    return res.json({ message: 'License renewed', expiresAt: currentExpiry.toISOString() });
  } catch (error) {
    console.error('Error renewing license:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ✅ 2. Revoke license by Firestore document ID (deviceId)
exports.revokeLicense = async (req, res) => {
  try {
    const { deviceId } = req.body;
    if (!deviceId) return res.status(400).json({ message: 'deviceId is required' });

    const userRef = db.collection('users').doc(deviceId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) return res.status(404).json({ message: 'User not found' });

    await userRef.update({ status: 'revoked', activated: false, expiresAt: null });

    return res.json({ message: 'License revoked' });
  } catch (error) {
    console.error('Error revoking license:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ✅ 3. Get license status by Firestore document ID
exports.getLicenseStatus = async (req, res) => {
  try {
    const { deviceId } = req.params;
    if (!deviceId) return res.status(400).json({ message: 'deviceId is required' });

    const userRef = db.collection('users').doc(deviceId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) return res.status(404).json({ message: 'User not found' });

    const userData = userDoc.data();

    const now = new Date();
    const expiresAt = userData.expiresAt ? new Date(userData.expiresAt) : null;
    const expired = expiresAt ? now > expiresAt : false;

    return res.json({
      deviceId,
      status: userData.status || 'unknown',
      activated: userData.activated || false,
      expiresAt: userData.expiresAt || null,
      expired,
      licenseType: userData.licenseType || 'unknown',
    });
  } catch (error) {
    console.error('Error fetching license status:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ✅ 4. Check device limit by license code
exports.checkDeviceLimit = async (req, res) => {
  try {
    const { licenseCode, maxDevices } = req.body;
    if (!licenseCode || !maxDevices) {
      return res.status(400).json({ message: 'licenseCode and maxDevices are required' });
    }

    const usersSnapshot = await db.collection('users').where('activationCode', '==', licenseCode).get();

    const activeDevices = usersSnapshot.docs.filter(doc => {
      const data = doc.data();
      return data.activated === true && (!data.status || data.status === 'active');
    }).length;

    if (activeDevices >= maxDevices) {
      return res.status(403).json({ message: 'Device limit reached' });
    }

    return res.json({ message: 'Device limit OK', activeDevices });
  } catch (error) {
    console.error('Error checking device limit:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ✅ 5. Get all licenses (document ID as deviceId)
exports.getAllLicenses = async (req, res) => {
  try {
    const snapshot = await db.collection('users').get();
    const now = new Date();

    const licenses = snapshot.docs.map(doc => {
      const data = doc.data();
      const expiresAt = data.expiresAt ? new Date(data.expiresAt) : null;
      const expired = expiresAt ? now > expiresAt : false;

      return {
        deviceId: doc.id, // ✅ Document ID used as deviceId
        activated: data.activated || false,
        status: data.status || 'unknown',
        expiresAt,
        expired,
        licenseType: data.licenseType || 'N/A',
        deviceInfo: data.deviceInfo || {},
        activationCode: data.activationCode || '',
      };
    });

    res.status(200).json(licenses);
  } catch (error) {
    console.error('Error fetching licenses:', error);
    res.status(500).json({ message: 'Failed to fetch license list' });
  }
};
