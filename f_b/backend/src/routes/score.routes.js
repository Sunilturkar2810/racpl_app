const express = require("express");
const router = express.Router();

const { verifyToken } = require("../middlewares/auth.middleware");

const {
  getScoreData,
  getScoreSummary,
} = require("../controllers/score.controller");

/* ✅ Table Score Data */
router.get("/", verifyToken, getScoreData);

/* ✅ Dashboard Cards Summary */
router.get("/summary", verifyToken, getScoreSummary);

module.exports = router;
