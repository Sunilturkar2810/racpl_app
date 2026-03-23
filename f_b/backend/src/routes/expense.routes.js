const express = require("express");
const router = express.Router();

const expenseController = require("../controllers/expense.controller");

const multer = require("multer");
const upload = multer({ storage: multer.memoryStorage() });
const { verifyToken } = require('../middlewares/auth.middleware');

// Employee Submit Expense
router.post(
  "/",
  verifyToken,
  upload.single("bill"),
  expenseController.createExpense
);

// Get All Expenses
router.get(
  "/",
  verifyToken,
  expenseController.getExpenses
);



// Edit Expense
router.put(
  "/edit/:id",
  verifyToken,
   upload.single("bill"),
    
  expenseController.editExpense
);

module.exports = router;
