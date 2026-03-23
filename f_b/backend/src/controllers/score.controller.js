const db = require("../config/db.config");
const { getWeekLabel } = require("../utils/weekHelper");

/* ==========================================
   ✅ GET SCORE (Fetch + Save in Sheet)
========================================== */
exports.getScoreData = async (req, res) => {
  try {
    // 1️⃣ Fetch Delegations
    const delegations = await db.getAll("delegation");

    let tasks = delegations.filter((d) => d.id);

    const { role, name: userName, email } = req.user;

    if (role !== "Admin" && role !== "SuperAdmin") {
      tasks = tasks.filter(
        (d) =>
          d.doer_name === userName ||
          d.delegator_name === userName ||
          d.doer_name === email ||
          d.delegator_name === email
      );
    }

    // 2️⃣ Clear Old Score Sheet Rows
    await db.clearSheet("score");

    // 3️⃣ Build Score Rows
    const now = new Date().toISOString();

    const scoreRows = tasks.map((d, index) => ({
      id: index + 1,
      delegation_id: d.id,

      name: d.doer_name,
      task: d.delegation_name,

      date: d.due_date,
      score: Number(d.revision_count || 0),

      status: d.status,

      week_no: getWeekLabel(d.due_date),

      created_at: now,
    }));

    // 4️⃣ Save Rows into Score Sheet
    for (let row of scoreRows) {
      await db.insertByHeader("score", row);
    }

    // 5️⃣ Return Response
    res.json({
      message: "✅ Score Updated & Returned Successfully",
      total: scoreRows.length,
      data: scoreRows,
    });
  } catch (err) {
    console.error("Score API Error:", err);
    res.status(500).json({ message: "Error fetching score data" });
  }
};


exports.getScoreSummary = async (req, res) => {
  try {
    const delegations = await db.getAll("delegation");

    // ✅ Valid Tasks
    let tasks = delegations.filter((d) => d.id);

    const { role, name: userName, email } = req.user;

    if (role !== "Admin" && role !== "SuperAdmin") {
      tasks = tasks.filter(
        (d) =>
          d.doer_name === userName ||
          d.delegator_name === userName ||
          d.doer_name === email ||
          d.delegator_name === email
      );
    }

    // ✅ Total Tasks
    const total = tasks.length;

    // ===============================
    // ✅ STATUS BASED COUNTS
    // ===============================

    // 🔴 Red = NEED REVISION
    const redTasks = tasks.filter(
      (t) => t.status === "NEED REVISION"
    ).length;

    // 🟡 Yellow = HOLD
    const yellowTasks = tasks.filter(
      (t) => t.status === "HOLD"
    ).length;

    // 🟢 Green = COMPLETED
    const greenTasks = tasks.filter(
      (t) => t.status === "COMPLETED"
    ).length;

    // ===============================
    // ✅ Percentage Function
    // ===============================
    const percent = (count) =>
      total > 0 ? ((count / total) * 100).toFixed(1) : 0;

    // ===============================
    // ✅ Response
    // ===============================
    res.json({
      totalTasks: total,

      red: {
        count: redTasks,
        percent: percent(redTasks),
      },

      yellow: {
        count: yellowTasks,
        percent: percent(yellowTasks),
      },

      green: {
        count: greenTasks,
        percent: percent(greenTasks),
      },
    });
  } catch (err) {
    console.error("Score Summary Error:", err);
    res.status(500).json({
      message: "Error calculating score summary",
    });
  }
};

