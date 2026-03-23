const sheets = require("../config/googleSheet");
require("dotenv").config();

const SPREADSHEET_ID = process.env.SPREADSHEET_ID;

const createMOMSheet = async () => {
  try {
   
    try {
      await sheets.spreadsheets.batchUpdate({
        spreadsheetId: SPREADSHEET_ID,
        requestBody: {
          requests: [{ addSheet: { properties: { title: "mom" } } }],
        },
      });
    } catch {
      // Sheet already exists → ignore
    }

    // ✅ Add Headers
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: "mom!A1:Z1",
      valueInputOption: "RAW",
      requestBody: {
        values: [[
          "id",
          "mom_id",
          "timestamp",

          // ✅ Created By Employee Info
          "created_by",
          "employee_name",
          "department",
          "email",

          // ✅ Meeting Details
          "project",
          "date",
          "time",
          "location",

          // ✅ Attendees (Dynamic)
          "ra_team_attendees",
          "client_team_attendees",
          "vendor_team_attendees",
          "other_attendees",

          // ✅ Minutes JSON Table
          "minutes",

          // ✅ Meta
          "created_at",
          "updated_at",
        ]],
      },
    });

    console.log("✅ MOM Sheet Ready");
  } catch (err) {
    console.error("MOM Sheet Error:", err);
  }
};

module.exports = { createMOMSheet };
