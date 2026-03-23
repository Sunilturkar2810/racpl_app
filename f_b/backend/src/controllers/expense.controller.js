const db = require("../config/db.config");
const { uploadToDrive } = require("../utils/googleDrive");

/**
 * ✅ CREATE EXPENSE
 */
exports.createExpense = async (req, res) => {
  try {
    const userId = req.user.id;

    // ✅ Fetch Employee Info from employees sheet
    const employee = await db.findById("employees", userId);

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    const {
      timestamp,
      category,
      amount,
      check_in,
      check_out,
      location,
      travel_type,
      from_location,
      to_location,
      km,
      toll_amount,
      other_description,
    } = req.body;

    // ✅ Upload Bill to Drive
    let bill_url = null;
    if (req.file) {
      bill_url = await uploadToDrive(
        req.file.buffer,
        `expense_${Date.now()}_${req.file.originalname}`,
        req.file.mimetype
      );
    }

    // ✅ Auto Increment Expense ID safely
    const allExpenses = await db.getAll("expenses");

    const nextId =
      allExpenses.length > 0
        ? Math.max(...allExpenses.map(e => Number(e.id))) + 1
        : 1;

    // ✅ Expense Data Object
    const expenseData = {
      id: nextId,

      timestamp: timestamp || new Date().toISOString(),

      user_id: userId,

      email: employee.Work_Email,
      employee_name: `${employee.First_Name} ${employee.Last_Name}`,
      mobile: employee.Mobile_Number,
      department: employee.Department,
      role: employee.Role,

      category,

      amount: amount ? Number(amount) : null,

      check_in: check_in || null,
      check_out: check_out || null,
      location: location || null,

      travel_type: travel_type || null,
      from_location: from_location || null,
      to_location: to_location || null,

      km: km ? Number(km) : null,
      toll_amount: toll_amount ? Number(toll_amount) : null,

      other_description: other_description || null,

      bill_url,


      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    // ✅ Insert into Google Sheet
    await db.insertByHeader("expenses", expenseData);

    res.status(201).json({
      message: "Expense Submitted Successfully",
      expense: expenseData,
    });
  } catch (err) {
    console.error("Expense Error:", err);
    res.status(500).json({ message: err.message });
  }
};


/**
 * ✅ GET EXPENSES (Employee vs Admin/HR)
 */
exports.getExpenses = async (req, res) => {
  try {
    const role = req.user.role;
    const userId = req.user.id;

    let expenses = await db.getAll("expenses");

    // ✅ Admin/HR → See All
    if (role === "Admin" || role === "HR") {
      return res.json(expenses);
    }

    // ✅ Employee → See Only Own Expenses
    const myExpenses = expenses.filter(
      (e) => String(e.user_id) === String(userId)
    );

    res.json(myExpenses);

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};



/**
 * ✅ EDIT EXPENSE
 */
exports.editExpense = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // 1. Ensure req.body exists (Safety check for multipart/form-data)
    if (!req.body) {
      return res.status(400).json({ message: "No data provided in request body" });
    }

    // 2. Load all expenses
    const expenses = await db.getAll("expenses");

    // 3. Find Expense Safely (Handling potential whitespace or ID type mismatches)
    const expense = expenses.find(
      (e) => String(e.id || "").trim() === String(id).trim()
    );

    if (!expense) {
      return res.status(404).json({
        message: `Expense with ID ${id} not found`,
      });
    }

    // 4. Permission Check (Optional: Only owner or Admin can edit)
    if (req.user.role !== "Admin" && String(expense.user_id) !== String(userId)) {
      return res.status(403).json({ message: "Unauthorized to edit this expense" });
    }

    // 5. Upload New Bill if provided
    let bill_url = expense.bill_url || null;
    if (req.file) {
      bill_url = await uploadToDrive(
        req.file.buffer,
        `expense_edit_${Date.now()}_${req.file.originalname}`,
        req.file.mimetype
      );
    }

    /**
     * 6. Prepare Updated Data Object
     * We use optional chaining (?.) and nullish coalescing (??) 
     * to prevent "undefined" crashes.
     */
    const updatedData = {
      // Keep existing user/id info
      ...expense, 

      // Update fields from req.body or keep existing
      category: req.body.category ?? expense.category,
      amount: req.body.amount !== undefined ? Number(req.body.amount) : expense.amount,
      location: req.body.location ?? expense.location,
      
      travel_type: req.body.travel_type ?? expense.travel_type,
      from_location: req.body.from_location ?? expense.from_location,
      to_location: req.body.to_location ?? expense.to_location,
      
      km: req.body.km !== undefined ? Number(req.body.km) : expense.km,
      toll_amount: req.body.toll_amount !== undefined ? Number(req.body.toll_amount) : expense.toll_amount,
      
      check_in: req.body.check_in ?? expense.check_in,
      check_out: req.body.check_out ?? expense.check_out,
      
      other_description: req.body.other_description ?? expense.other_description,
      
      bill_url: bill_url,
      updated_at: new Date().toISOString(),
    };

    // 7. Update Row in Sheet
    // Note: ensure your db.updateById uses the correct ID column
    await db.updateById("expenses", id, updatedData);

    res.json({
      message: "✅ Expense Updated Successfully",
      updatedExpense: updatedData,
    });

  } catch (err) {
    console.error("Edit Expense Error:", err);
    res.status(500).json({ message: err.message || "Internal Server Error" });
  }
};