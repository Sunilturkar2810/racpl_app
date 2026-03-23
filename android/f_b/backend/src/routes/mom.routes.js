const express = require("express");
const router = express.Router();
const { verifyToken } = require('../middlewares/auth.middleware');
const {
  createMOM,
  getAllMOM,
  editMOM,
} = require("../controllers/mom.controller");


router.post("/",verifyToken, createMOM);

router.get("/", verifyToken,getAllMOM);

router.put("/:id",verifyToken, editMOM);

module.exports = router;
