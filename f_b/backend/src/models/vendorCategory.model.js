const sheets = require("../config/googleSheet");
require("dotenv").config();

const SPREADSHEET_ID = process.env.SPREADSHEET_ID;
const SHEET_NAME = "vendor_categories";


const DEFAULT_VENDOR_CATEGORIES = [
  "CIVIL CONTRACTOR",
  "PEB CONTRACTOR",
  "LABOUR CONTRACTOR",
  "FIRE CONTRACTOR",
  "CRANE VENDOR",
  "MEPF VENDOR",
  "INTERIOR CONTRACTOR",
  "ELECTRICAL CONTRACTOR",
  "FABRICATOR",
  "HYDRAULIC HOSE MANUFACTURERS",
  "STP CONTRACTOR",
  "GEOTECHNICAL / SOIL INVESTIGATION & LAND SURVEYING",
  "DOOR WINDOWS- ALUMINIUM CONTRACTOR",
  "LIFT CONTRACTOR",
  "ROLLING SHUTTER CONTRACTOR",
  "WATER PROOFING CONTRACTOR",
  "CONCRETE FLOORING CONTRACTOR",
  "ELECTRICAL CONSULTANTS",
  "PVC, UPVC CONTRACTOR",
  "GLASS CONTRACTOR",
  "HVAC CONTRACTOR",
  "LIAISON CONSULTANTS",
  "SLIDING GATE & BOOM BARRIER CONTRACTOR",
  "STP, ETP, RO CONTRACTOR",
  "RACKS CONTRACTOR",
  "COOLING TOWER CONTRACTOR",
  "WEIGHING BRIDGE CONTRACTOR",
  "TILE CONTRACTOR",
  "FENCING CONTRACTOR",
  "PAINT SOLUTION CONTRACTOR",
  "STRUCTURAL CONSULTANTS",
  "FIRE CONSULTANTS",
  "PLUMBING CONSULTANTS",
  "MEP CONSULTANTS",
  "MEP CONTRACTOR",
  "EPOXY FLOORING CONTRACTOR",
  "FALSE CEILING CONTRACTOR",
  "FIRE DETECTION & ALARM SYSTEM",
  "ACOUSTICS CEILING & WALLS CONTRACTOR",
  "KITCHENS CONTRACTOR",
  "CONSTRUCTION CHEMICALS CONTRACTOR",
  "STONE CONTRACTOR",
  "FRP MANHOLE COVERS",
  "INDUSTRIAL ESD FLOORING CONTRACTOR",
  "GANTRY CONTRACTOR",
  "HAND RAIL CONTRACTOR",
  "VASTU CONSULTANTS",
  "RACKING & STORAGE SOLUTIONS",
  "INSULATION CONTRACTOR",
  "STEEL FIBER CONTRACTOR",
  "PRECAST BUILDING SYSTEMS",
  "GOOD LIFT CONTRACTOR",
  "ROOF SHEETING CONTRACTOR",
  "SOLAR PANELS CONTRACTOR",
  "SCAFFOLDING & FORMWORK CONTRACTOR",
  "CRANES CONTRACTOR",
  "INDUSTRIAL AIR COOLING",
  "FIRE FIGHTING VENDOR",
  "STORAGE TANK CONTRACTOR",
  "INTERIOR DESIGNER / FURNITURE MANUFACTURING",
  "QUANTITY SURVEYING",
  "FIRE EXIT DOOR",
  "WIRES & CABLES",
  "STONE CLADDING",
  "GREEN BUILDING CONSULTANTS",
  "MATERIAL HANDLING EQUIPMENT",
];


const createVendorCategorySheet = async () => {
  try {
    /* 1️⃣ Create Sheet if Not Exists */
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

      console.log("✅ Vendor Categories sheet created");
    } catch {
      console.log("⚡ Vendor Categories sheet already exists");
    }

    /* 2️⃣ Ensure Header Row */
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: `${SHEET_NAME}!A1:D1`,
      valueInputOption: "RAW",
      requestBody: {
        values: [["id", "name", "status", "created_at"]],
      },
    });

    /* 3️⃣ Check Existing Rows */
    const res = await sheets.spreadsheets.values.get({
      spreadsheetId: SPREADSHEET_ID,
      range: `${SHEET_NAME}!A2:A`,
    });

    const existingRows = res.data.values || [];

    /* 4️⃣ Seed Default Vendor Categories if Empty */
    if (existingRows.length === 0) {
      const now = new Date().toISOString();

      const seedRows = DEFAULT_VENDOR_CATEGORIES.map((name, index) => [
        index + 1,
        name,
        "ACTIVE",
        now,
      ]);

      await sheets.spreadsheets.values.append({
        spreadsheetId: SPREADSHEET_ID,
        range: `${SHEET_NAME}!A:D`,
        valueInputOption: "USER_ENTERED",
        requestBody: {
          values: seedRows,
        },
      });

      console.log("✅ Vendor Categories seeded successfully");
    } else {
      console.log("⚡ Vendor Categories already seeded");
    }
  } catch (err) {
    console.error("❌ Error creating vendor categories sheet:", err);
    throw err;
  }
};

module.exports = {
  createVendorCategorySheet,
};
