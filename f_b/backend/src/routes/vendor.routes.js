const express = require("express");
const router = express.Router();

const vendorController = require("../controllers/vendor.controller");

const multer = require("multer");
const upload = multer({ storage: multer.memoryStorage() });
const { verifyToken } = require('../middlewares/auth.middleware');

// Employee Submit Vendor
router.post(
  "/",
  verifyToken,
  upload.single("profile_doc"),
  vendorController.createVendor
);

// Get All Vendors
router.get(
  "/",
  verifyToken,
  vendorController.getAllVendors
);



// Edit Vendor
router.put(
  "/:id",
  verifyToken,
   upload.single("profile_doc"),
    
  vendorController.editVendor
);

module.exports = router;
