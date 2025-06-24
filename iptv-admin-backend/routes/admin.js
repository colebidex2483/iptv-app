const express = require('express');
const router = express.Router();

const activationController = require('../controllers/activationController');
const licenseController = require('../controllers/licenseController'); // Add this

// Existing routes, e.g., activation code routes
router.post('/activate', activationController.validateCode);
router.post('/generate-code', activationController.generateCode);
router.get('/codes', activationController.getAllCodes);
router.delete('/codes/:code', activationController.deleteCode);

// Add license management routes here:
router.post('/license/renew', licenseController.renewLicense);
router.post('/license/revoke', licenseController.revokeLicense);
router.get('/license/status/:deviceId', licenseController.getLicenseStatus);
router.post('/license/check-device-limit', licenseController.checkDeviceLimit);

router.get('/users', licenseController.getAllLicenses);

module.exports = router;
