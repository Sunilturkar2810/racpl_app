const sheets = require("../config/googleSheet");
require("dotenv").config();

const SPREADSHEET_ID = process.env.SPREADSHEET_ID;
const SHEET_NAME = "vendors";

const createVendorSheet = async () => {
  try {
    // ✅ Create Sheet if Missing
    try {
      await sheets.spreadsheets.batchUpdate({
        spreadsheetId: SPREADSHEET_ID,
        requestBody: {
          requests: [
            {
              addSheet: {
                properties: { title: SHEET_NAME },
              },
            },
          ],
        },
      });
      console.log("✅ Vendors sheet created");
    } catch {
      console.log("⚡ Vendors sheet already exists");
    }

    // ✅ Header Row
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: `${SHEET_NAME}!A1:T1`,
      valueInputOption: "RAW",
      requestBody: {
        values: [
            [
 "id",
 "vendor_id",
 "company_name",
 "email",
 "location",
 "address",
 "contact_person",
 "contact_number",
 "profile_name",

 "categories",
 "sub_categories",

 "suggested_by",
 "website_url",
 "linkedin_url",
 "projects",

 "profile_doc_type",
 "profile_doc_value",

 "created_at",
 "updated_at"
]

    ],
      },
    });

    console.log("✅ Vendor Sheet Ready");
  } catch (err) {
    console.error("❌ Vendor Sheet Error:", err);
    throw err;
  }
};

module.exports = { createVendorSheet };
