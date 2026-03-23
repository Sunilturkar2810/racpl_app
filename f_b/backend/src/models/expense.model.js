const sheets = require("../config/googleSheet");
require("dotenv").config();

const SPREADSHEET_ID = process.env.SPREADSHEET_ID;

const createExpenseSheet = async () => {
  try {
    // Create Sheet if not exists
    try {
      await sheets.spreadsheets.batchUpdate({
        spreadsheetId: SPREADSHEET_ID,
        requestBody: {
          requests: [{ addSheet: { properties: { title: "expenses" } } }],
        },
      });
    } catch {}

    // Add Headers
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: "expenses!A1:Z1",
      valueInputOption: "RAW",
      requestBody: {
        values: [[
          "id",
          "timestamp",
          "email",
          "employee_name",
          "mobile",
          "department",
          "role",

          "category",
          "amount",

          "check_in",
          "check_out",
          "location",

          "travel_type",
          "from_location",
          "to_location",
          "km",
          "toll_amount",

          "other_description",

          "bill_url",
          "created_at",
          "updated_at",
        ]],
      },
    });

    console.log("✅ Expenses Sheet Ready");
  } catch (err) {
    console.error("Expense Sheet Error:", err);
  }
};

module.exports = { createExpenseSheet };
