const sheets = require("../config/googleSheet");
require("dotenv").config();

const SPREADSHEET_ID = process.env.SPREADSHEET_ID;
const SHEET_NAME = "projects";

// ✅ Default Projects List
const DEFAULT_PROJECTS = [
  "336- UKB ELECTRONICS- INTERIORS,GILOTH",
  "358- RP STEEL,  HARYANA",
];

const createProjectSheet = async () => {
  try {
    // 1️⃣ Create sheet if not exists
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

      console.log("Projects sheet created");
    } catch {
      console.log("Projects sheet already exists");
    }

    // 2️⃣ Ensure header row (32 columns)
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: `${SHEET_NAME}!A1:AF1`,
      valueInputOption: "RAW",
      requestBody: {
        values: [
          [
            "id",             // 0
            "name",           // 1
            "address",        // 2
            "location",       // 3
            "client_name",    // 4
            "contact_no",     // 5
            "status",         // 6
            "date_of_app",    // 7
            "team_lead",      // 8
            "award_letter",   // 9
            "award_letter_remark", // 10
            "land_paper_zonning", // 11
            "land_paper_zonning_remark", // 12
            "soil_testing",   // 13
            "soil_testing_remark", // 14
            "survey",         // 15
            "water_testing",  // 16
            "water_testing_remark", // 17
            "plot_demarcation_by_govt", // 18
            "plot_demarcation_by_govt_remark", // 19
            "far_purchase",   // 20
            "building_plan_approval", // 21
            "building_plan_remark", // 22
            "revised_building_plan", // 23
            "factory_act_consultant", // 24
            "firefighting_approval", // 25
            "dpc_certificate", // 26
            "dpc_certificate_remark", // 27
            "fire_noc",       // 28
            "labour_cess",    // 29
            "solar_haredan_oc", // 30
            "created_at",     // 31
          ],
        ],
      },
    });

    // 3️⃣ Check if already seeded
    const res = await sheets.spreadsheets.values.get({
      spreadsheetId: SPREADSHEET_ID,
      range: `${SHEET_NAME}!A2:A`,
    });

    const existingRows = res.data.values || [];

    // 4️⃣ Seed projects if empty
    if (existingRows.length === 0) {
      const now = new Date().toISOString();

      const seedRows = DEFAULT_PROJECTS.map((name, index) => {
        const row = new Array(32).fill("");
        row[0] = index + 1;
        row[1] = name;
        row[2] = "N/A"; // address
        row[3] = "N/A"; // location
        row[4] = "N/A"; // client_name
        row[5] = "N/A"; // contact_no
        row[6] = "Active"; // status
        row[7] = ""; // date_of_app
        row[8] = ""; // team_lead
        row[31] = now; // created_at
        return row;
      });

      await sheets.spreadsheets.values.append({
        spreadsheetId: SPREADSHEET_ID,
        range: `${SHEET_NAME}!A:AF`,
        valueInputOption: "USER_ENTERED",
        requestBody: {
          values: seedRows,
        },
      });

      console.log("Seed projects added");
    } else {
      console.log("Projects already seeded");
    }
  } catch (err) {
    console.error("Error creating projects sheet:", err);
    throw err;
  }
};

module.exports = {
  createProjectSheet,
};
