const sheets = require("../config/googleSheet");
require("dotenv").config();

const SPREADSHEET_ID = process.env.SPREADSHEET_ID;
const SHEET_NAME = "projects";

// ✅ Default Projects List
const DEFAULT_PROJECTS = [
  "229- ENGELBERG GROUP HOUSE, IMT MANESAR",
  "290-KL EXPORT PVT. LTD. , FARIDABAD",
  "336- UKB ELECTRONICS- INTERIORS,GILOTH",
  "358- RP STEEL,  HARYANA",
  "362- OIL & GAS, FARIDABAD",
  "373- NATIONAL PRODUCTS, GHILOTH",
  "375- POLYLACE INDIA , BAWAL",
  "377- KAMINI JAIN RATHDHANA , SONIPAT",
  "389- JSH PACKAGING, BAWAL",
  "401- VIP PLASTICS, KUNDLI",
  "346- SVARN INFRATEL EBEAM, 1.0 Mev, PALWAL",
  "414- SVARN INFRATEL , GHILOTH",
  "428- SVARN EXPANSION , PALWAL",
  "429- ENVOYS, IMT MANESAR",
  "431- VAISHNO INDIA, IMT FARIDABAD",
  "438- SAMARPAN HOSPITAL, KUNDLI",
  "440- SB ECOM,IMT FARIDABAD",
  "441- AD CHEM, GILOTH",
  "447- SHAKTI PULLY, ROHTAK",
  "452- DE NOVO ,GURUGRAM",
  "453- LARAON INDIA",
  "454- AGROMACH , PALWAL",
  "456- HRF FARMHOUSE, MANESAR",
  "457- GOMEGA CREATIONS, GILOTH",
  "459- K2 GROUP HOUSING, IMT MANESAR",
  "461- WIPE HOTWIRE , NEEMRANA",
  "465- INSULATION SOLUTION , KHARKHAUDA",
  "466- TATA STEEL , NEW DELHI",
  "468- APL FOOTWEAR, NATHUPUR",
  "469- GURU AMARDASS, NOIDA",
  "471- SKAS, NEW DELHI",
  "472- MRK HEALTHCARE , GUJARAT",
  "475- NEW INDIA SURFACTANTS PVT. LTD. , HYDERABAD",
  "476- AFFLATUS , GURUGRAM",
  "478- TRINATH, SRI CITY(ANDHRA PRADESH)",
  "480- M/S.MADHU KHARBANDA, IMT MANESAR",
  "482- PACE CITY , GURUGRAM",
  "483- SAATVIK GREEN , AMBALA",
  "484- ADVANCE ANMOL COMMERCIAL  , FARIDABAD",
  "485- M/S.BUKAKA THREE D INTEGRATED SOLUTIONS LTD.,GHILOTH",
  "487- UNIGLOBE EXPORTS PRIVATE LIMITED,JODHPUR",
  "491- SUMIT INDUSTRIAL GEARS LLP , ROHTAK",
  "492- SENIOR LIVING, RAJASTHAN",
  "495- KRN HVAC PRODUCTS PVT. LTD. NEEMRANA",
  "497-SUMIT ENGINEERS,FARIDABAD",
  "498- HITAISHI HOSPITAL,PITAMPURA",
  "500- KAMAL RUBPLAST INDUSTRIES,JHAJJAR",
  "501- UNICORN MEDIDENT, MANESAR",
  "503- GOLD CRAFT , DWARKA",
  "504- M/S KAN PLAST PVT. LTD. , ALIGARH",
  "505- AAN CLOTHING,GURGAON",
  "507- AJAY JI EBD-65, GURGAON",
  "508- TSKEI INDIA PVT. LTD.,NEEMRANA",
  "509- SMILE ,VIZAG",
  "510- BEC CONDUIT PVT. LTD. , YEIDA",
  "511- RHINE POWER, ROHAD",
  "512- CLEAR PACK, GREATER NOIDA",
  "514- NAVJEEVAN HOSPITAL,PITAMPURA",
  "515- SONA SIGNATURE, GURUGRAM",
  "516- SAFEX EXPANSION , KESHWANA",
  "517- BODYCARE CREATIONS,HAPUR",
  "518- ATLANTIS, RUDRAPUR",
  "519- MAGNOLIA , NARNAUL",
  "520- LAPP INDIA EXPANSION,BHOPAL",
  "521- ACEDS, BHOPAL",
  "522- SSP BUILDING UFLEX , PANIPAT",
  "523- MAHAVEER BUSINESS PARK,RAIPUR",
  "524- M/S MARC SALON FURNITURE & BEAUITY EQUIPMENTS,MANESAR",
  "525- PALLAVI COPPER DMIC, NOIDA",
  "526- SAI AUTO , PRITHLA",
  "527- MOHAN PACKAGING",
  "528- NEW THREE D INTEGRATED SOLUTIONS LTD.,ALWAR",
  "529- INULIFE BIOFIBRES LLP, BHIWADI",
  "530- POLYLACE EXPANSION, BAWAL",
  "532- VICTORA",
  "535- MC OFFICE REWARI",
  "461A- WIPE HOTWIRE NEW EXPANSION, NEEMRANA"
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

    // 2️⃣ Ensure header row
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: `${SHEET_NAME}!A1:L1`,
      valueInputOption: "RAW",
      requestBody: {
        values: [["id", "name", "location", "client_name", "status", "description", "start_date", "end_date", "budget", "project_manager", "contractor", "created_at"]],
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

      const seedRows = DEFAULT_PROJECTS.map((name, index) => [
        index + 1,
        name,
        "N/A", // location
        "N/A", // client_name
        "Active", // status
        "Default seeded project", // description
        "", // start_date
        "", // end_date
        "", // budget
        "", // project_manager
        "", // contractor
        now,
      ]);

      await sheets.spreadsheets.values.append({
        spreadsheetId: SPREADSHEET_ID,
        range: `${SHEET_NAME}!A:L`,
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
