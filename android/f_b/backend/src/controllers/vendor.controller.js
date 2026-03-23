const db = require("../config/db.config");
const { uploadToDrive } = require("../utils/googleDrive");

/* ===========================================
   ✅ Helper: Safe Parse JSON Arrays from FormData
=========================================== */
const safeParse = (value) => {
  if (!value) return [];
  if (Array.isArray(value)) return value;

  try {
    return JSON.parse(value);
  } catch {
    return [];
  }
};

/* ===========================================
   ✅ CREATE VENDOR
=========================================== */
exports.createVendor = async (req, res) => {
  try {
    const {
      company_name,
      email,
      location,
      address,
      contact_person,
      contact_number,
      profile_name,

      categories,
      sub_categories,
      projects,

      suggested_by,
      website_url,
      linkedin_url,

      profile_doc_type,
      profile_doc_value,
    } = req.body;

    /* ===========================================
       ✅ PROFILE DOCUMENT LOGIC
    =========================================== */

    let finalDocValue = profile_doc_value || "";

    // ✅ Upload File Option
    if (profile_doc_type === "Upload_File") {
      if (req.file) {
        finalDocValue = await uploadToDrive(
          req.file.buffer,
          req.file.originalname,
          req.file.mimetype
        );
      } else {
        return res.status(400).json({
          message: "File required for Upload_File option",
        });
      }
    }

    // ✅ External Link Option
    if (profile_doc_type === "EXTERNAL") {
      if (!profile_doc_value) {
        return res.status(400).json({
          message: "External link required for EXTERNAL option",
        });
      }
    }

    /* ===========================================
       ✅ Auto Increment ID
    =========================================== */

    const allVendors = await db.getAll("vendors");

    const nextId =
      allVendors.length > 0
        ? Math.max(...allVendors.map((v) => Number(v.id))) + 1
        : 1;

    const vendor_id = `VENDOR-${Date.now()}`;

    /* ===========================================
       ✅ Vendor Data Object
    =========================================== */

    const vendorData = {
      id: nextId,
      vendor_id,

      company_name,
      email,
      location,
      address,
      contact_person,
      contact_number,
      profile_name,

      // ✅ Multi Select Stored as JSON
      categories: JSON.stringify(safeParse(categories)),
      sub_categories: JSON.stringify(safeParse(sub_categories)),
      projects: JSON.stringify(safeParse(projects)),

      suggested_by: suggested_by || "",
      website_url: website_url || "",
      linkedin_url: linkedin_url || "",

      profile_doc_type,
      profile_doc_value: finalDocValue,

      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    // ✅ Insert into Google Sheet
    await db.insertByHeader("vendors", vendorData);

    res.status(201).json({
      message: "✅ Vendor Created Successfully",
      vendor: vendorData,
    });
  } catch (err) {
    console.error("Vendor Create Error:", err);
    res.status(500).json({ message: err.message });
  }
};

/* ===========================================
   ✅ GET ALL VENDORS
=========================================== */
exports.getAllVendors = async (req, res) => {
  try {
    const vendors = await db.getAll("vendors");

    const result = vendors
      .filter((v) => v.id)
      .map((v) => ({
        ...v,

        // ✅ Convert JSON String Back to Array
        categories: JSON.parse(v.categories || "[]"),
        sub_categories: JSON.parse(v.sub_categories || "[]"),
        projects: JSON.parse(v.projects || "[]"),
      }))
      .sort((a, b) => Number(b.id) - Number(a.id));

    const { role, email } = req.user;
    let filteredResult = result;

    if (role !== "Admin" && role !== "SuperAdmin") {
      filteredResult = result.filter((v) => v.suggested_by === email);
    }

    res.json(filteredResult);
  } catch (err) {
    console.error("Vendor Fetch Error:", err);
    res.status(500).json({ message: "Error fetching vendors" });
  }
};

/* ===========================================
   ✅ EDIT VENDOR
=========================================== */
exports.editVendor = async (req, res) => {
  try {
    const { id } = req.params;

    // ✅ Fetch All Vendors
    const vendors = await db.getAll("vendors");

    // ✅ Find Vendor by ID
    const existingVendor = vendors.find(
      (v) => String(v.id).trim() === String(id).trim()
    );

    if (!existingVendor) {
      return res.status(404).json({ message: "Vendor not found" });
    }

    const {
      profile_doc_type,
      profile_doc_value,
      categories,
      sub_categories,
      projects,
    } = req.body;

    /* ===========================================
       ✅ PROFILE DOCUMENT UPDATE LOGIC
    =========================================== */

    let finalDocValue = existingVendor.profile_doc_value;

    // ✅ Upload New File Only If Provided
    if (profile_doc_type === "Upload_File") {
      if (req.file) {
        finalDocValue = await uploadToDrive(
          req.file.buffer,
          req.file.originalname,
          req.file.mimetype
        );
      }
      // ✅ No file → keep old file
    }

    // ✅ External Link Update
    if (profile_doc_type === "EXTERNAL") {
      finalDocValue = profile_doc_value || "";
    }

    /* ===========================================
       ✅ Updated Data Object
    =========================================== */

    const updatedData = {
      ...req.body,

      // ✅ Multi Select Safe Update
      categories: JSON.stringify(safeParse(categories)),
      sub_categories: JSON.stringify(safeParse(sub_categories)),
      projects: JSON.stringify(safeParse(projects)),

      profile_doc_type,
      profile_doc_value: finalDocValue,

      updated_at: new Date().toISOString(),
    };

    // ✅ Update in Google Sheet
    await db.updateById("vendors", id, updatedData);

    res.json({
      message: "✅ Vendor Updated Successfully",
      updated: updatedData,
    });
  } catch (err) {
    console.error("Vendor Edit Error:", err);
    res.status(500).json({ message: "Error updating vendor" });
  }
};
