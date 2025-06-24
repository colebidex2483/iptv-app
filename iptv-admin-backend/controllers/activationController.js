// controllers/activationController.js
const db = require('../services/firestoreService');

// ✅ Validate and activate device
// ✅ Validate Activation Code and store deviceInfo
exports.validateCode = async (req, res) => {
  try {
    console.log('Request body:', req.body);
    const { code, deviceId, deviceInfo } = req.body;

    if (!code) {
      return res.status(400).json({ message: 'Code is required' });
    }
    if (!deviceId && !(deviceInfo && deviceInfo.mac)) {
      return res.status(400).json({ message: 'deviceId or deviceInfo.mac is required' });
    }

    // Use deviceId if provided, else fallback to deviceInfo.mac
    const deviceKey = deviceId || deviceInfo.mac;

    // Try fetching doc by doc ID (code)
    let codeRef = db.collection('activation_codes').doc(code);
    let codeDoc = await codeRef.get();

    // If not found by doc ID, try querying by 'code' field (case-insensitive)
    if (!codeDoc.exists) {
      const codeQuery = await db.collection('activation_codes')
        .where('code', '==', code.toUpperCase())
        .limit(1)
        .get();

      if (codeQuery.empty) {
        return res.status(404).json({ message: 'Activation code does not exist' });
      }

      codeDoc = codeQuery.docs[0];
      codeRef = codeDoc.ref;
    }

    const codeData = codeDoc.data();

    // Check if code is already used and assigned to another device
    if (codeData.isUsed && codeData.assignedTo !== deviceKey) {
      return res.status(403).json({ message: 'Activation code already used by another device' });
    }

    // Check existing user record for deviceKey
    const userRef = db.collection('users').doc(deviceKey);
    const userDoc = await userRef.get();

    const now = new Date();

    if (userDoc.exists) {
      const userData = userDoc.data();
      if (userData.expiresAt && new Date(userData.expiresAt) > now) {
        return res.status(200).json({
          message: 'Device already activated',
          expiresAt: userData.expiresAt,
        });
      } else {
        return res.status(403).json({ message: 'Activation expired' });
      }
    }

    // Activate now
    const usedAt = now.toISOString();
    const expiresAt = new Date(now);
    expiresAt.setMonth(expiresAt.getMonth() + 1);

    // Update code doc
    await codeRef.update({
      isUsed: true,
      assignedTo: deviceKey,
      usedAt,
      expiresAt: expiresAt.toISOString(),
      deviceInfo: deviceInfo || null,
    });

    // Create or update user doc
    await userRef.set({
      activationCode: codeData.code,
      activated: true,
      expiresAt: expiresAt.toISOString(),
      deviceInfo: deviceInfo || null,
    });

    return res.status(200).json({
      message: 'Device activated successfully',
      expiresAt: expiresAt.toISOString(),
    });
  } catch (error) {
    console.error('Error validating activation code:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};


// ✅ Generate activation code
// ✅ Generate Activation Code with expiresAt
exports.generateCode = async (req, res) => {
  try {
    const newCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    const codeDoc = await db.collection('activation_codes').doc(newCode).get();
    if (codeDoc.exists) {
      return res.status(409).json({ message: 'Duplicate code generated. Try again.' });
    }

    const now = new Date();
    const expiresAt = new Date();
    expiresAt.setMonth(expiresAt.getMonth() + 1);

    await db.collection('activation_codes').doc(newCode).set({
      code: newCode,
      isUsed: false,
      assignedTo: null,
      createdAt: now.toISOString(),
      usedAt: null,
      expiresAt: expiresAt.toISOString(),
      deviceInfo: null,
    });

    return res.status(201).json({
      message: 'Activation code generated successfully',
      code: newCode,
      expiresAt: expiresAt.toISOString(),
    });
  } catch (error) {
    console.error('Error generating activation code:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ✅ List all activation codes
exports.getAllCodes = async (req, res) => {
  try {
    const snapshot = await db.collection('activation_codes').get();
    const codes = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.json({ codes });
  } catch (error) {
    console.error('Error fetching activation codes:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ✅ Search activation codes
exports.searchCodes = async (req, res) => {
  try {
    let { code = '', status, limit = 10, pageToken } = req.query;
    limit = parseInt(limit);

    let query = db.collection('activation_codes');
    if (status) query = query.where('isUsed', '==', status.toLowerCase() === 'used');

    code = code.toUpperCase().trim();
    if (code) {
      const endCode = code.slice(0, -1) + String.fromCharCode(code.charCodeAt(code.length - 1) + 1);
      query = query.orderBy('code').startAt(code).endBefore(endCode);
    } else {
      query = query.orderBy('code');
    }

    if (pageToken) {
      const lastDoc = await db.collection('activation_codes').doc(pageToken).get();
      if (lastDoc.exists) query = query.startAfter(lastDoc);
    }

    const snapshot = await query.limit(limit).get();
    const codes = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    const nextPageToken = snapshot.docs.length ? snapshot.docs[snapshot.docs.length - 1].id : null;

    return res.json({ codes, nextPageToken });
  } catch (error) {
    console.error('Error searching codes:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ✅ Delete code
exports.deleteCode = async (req, res) => {
  try {
    const { code } = req.params;
    const doc = await db.collection('activation_codes').doc(code).get();
    if (!doc.exists) return res.status(404).json({ message: 'Code not found' });

    await db.collection('activation_codes').doc(code).delete();
    return res.json({ message: `Code ${code} deleted` });
  } catch (error) {
    console.error('Error deleting code:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// ✅ Invalidate code
exports.invalidateCode = async (req, res) => {
  try {
    const { code } = req.params;
    const doc = await db.collection('activation_codes').doc(code).get();
    if (!doc.exists) return res.status(404).json({ message: 'Code not found' });

    await db.collection('activation_codes').doc(code).update({
      isUsed: true,
      assignedTo: null,
      usedAt: new Date().toISOString(),
      deviceInfo: null,
    });

    return res.json({ message: `Code ${code} invalidated` });
  } catch (error) {
    console.error('Error invalidating code:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
