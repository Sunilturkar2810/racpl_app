const express = require('express');
const router = express.Router();
const IMSMateriallController = require('../controllers/materialIMS.controller');
const { verifyToken } = require('../middlewares/auth.middleware');

// Config Routes
router.get('/material', verifyToken, IMSMateriallController.getAllMasters);



module.exports = router;
