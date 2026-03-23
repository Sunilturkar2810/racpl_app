const sheets = require("../config/googleSheet");
require("dotenv").config();

const SPREADSHEET_ID = process.env.SPREADSHEET_ID;
const SHEET_NAME = "score";

const createScoreSheet = async () => {
  try {
    /* ================= SCORE SHEET ================= */

    // 1️⃣ Create Sheet if Not Exists
    try {
      await sheets.spreadsheets.batchUpdate({
        spreadsheetId: SPREADSHEET_ID,
        requestBody: {
          requests: [
            {
              addSheet: {
                properties: {
                  title: SHEET_NAME,
                },
              },
            },
          ],
        },
      });

      console.log("✅ Score sheet created");
    } catch {
      console.log("⚡ Score sheet already exists");
    }

    // 2️⃣ Ensure Header Row
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: `${SHEET_NAME}!A1:I1`,
      valueInputOption: "RAW",
      requestBody: {
        values: [[
          "id",
          "delegation_id",

          "name",          // doer_name
          "task",          // delegation_name

          "date",          // due_date
          "score",         // revision_count

          "status",
          "week_no",       // Week 39/2025

          "created_at"
        ]],
      },
    });

    console.log("✅ Score sheet ensured successfully");
  } catch (err) {
    console.error("❌ Error creating score sheet:", err);
    throw err;
  }
};

module.exports = {
  createScoreSheet,
};
