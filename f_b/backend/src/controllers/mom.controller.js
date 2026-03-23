const db = require("../config/db.config");



exports.createMOM = async (req, res) => {
  try {
    const userId = req.user.id;

    const employee = await db.findById("employees", userId);

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    const {
      project,
      date,
      time,
      location,

      ra_team_attendees,
      client_team_attendees,
      vendor_team_attendees,
      other_attendees,

      minutes,
    } = req.body;

    // ✅ Auto Increment ID
    const allMOMs = await db.getAll("mom");

    const nextId =
      allMOMs.length > 0
        ? Math.max(...allMOMs.map(m => Number(m.id))) + 1
        : 1;

    // ✅ Unique MOM Code
    const mom_id = `MOM-${Date.now()}`;

    // ✅ MOM Data Object (FIXED)
    const momData = {
      id: nextId,
      mom_id,

      timestamp: new Date().toISOString(),

      created_by: userId,
      employee_name: `${employee.First_Name} ${employee.Last_Name}`,
      department: employee.Department,
      email: employee.Work_Email,

      project: project || null,
      date: date || null,
      time: time || null,
      location: location || null,

      // ✅ Store Attendees in Separate Columns
      ra_team_attendees: JSON.stringify(ra_team_attendees || []),
      client_team_attendees: JSON.stringify(client_team_attendees || []),
      vendor_team_attendees: JSON.stringify(vendor_team_attendees || []),
      other_attendees: JSON.stringify(other_attendees || []),

      // ✅ Minutes JSON Table
      minutes: JSON.stringify(minutes || []),

      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    // ✅ Insert into Google Sheet
    await db.insertByHeader("mom", momData);

    res.status(201).json({
      message: "MOM Created Successfully",
      mom: momData,
    });
  } catch (err) {
    console.error("MOM Create Error:", err);
    res.status(500).json({ message: err.message });
  }
};



// ✅ GET ALL MOM
exports.getAllMOM = async (req, res) => {
  try {
    const moms = await db.getAll("mom");

    const result = moms
      .map(m => ({
        id: m.id,
        mom_id: m.mom_id,
        timestamp: m.timestamp,

        created_by: m.created_by,
        employee_name: m.employee_name,
        department: m.department,
        email: m.email,

        project: m.project,
        date: m.date,
        time: m.time,
        location: m.location,

        // ✅ Parse Attendees JSON Safely
        ra_team_attendees: JSON.parse(m.ra_team_attendees || "[]"),
        client_team_attendees: JSON.parse(m.client_team_attendees || "[]"),
        vendor_team_attendees: JSON.parse(m.vendor_team_attendees || "[]"),
        other_attendees: JSON.parse(m.other_attendees || "[]"),

        // ✅ Parse Minutes JSON
        minutes: JSON.parse(m.minutes || "[]"),

        created_at: m.created_at,
        updated_at: m.updated_at,
      }))
      .sort((a, b) => Number(b.id) - Number(a.id)); // Latest First

    const { role, id: userId, email } = req.user;
    let filteredResult = result;

    if (role !== "Admin" && role !== "SuperAdmin") {
      filteredResult = result.filter(
        (m) => String(m.created_by) === String(userId) || m.email === email
      );
    }

    res.json(filteredResult);
  } catch (err) {
    console.error("Get MOM Error:", err);
    res.status(500).json({ message: "Error fetching MOM records" });
  }
};






// ✅ EDIT MOM
exports.editMOM = async (req, res) => {
  try {
    const { id } = req.params;

    // ✅ Instead of findById()
    const moms = await db.getAll("mom");

    const existingMOM = moms.find(
      (m) => String(m.id).trim() === String(id).trim()
    );

    if (!existingMOM) {
      return res.status(404).json({ message: "MOM not found" });
    }

    const {
      project,
      date,
      time,
      location,
      ra_team_attendees,
      client_team_attendees,
      vendor_team_attendees,
      other_attendees,
      minutes,
    } = req.body;

    const updatedData = {
      project: project ?? existingMOM.project,
      date: date ?? existingMOM.date,
      time: time ?? existingMOM.time,
      location: location ?? existingMOM.location,

      ra_team_attendees: JSON.stringify(
        ra_team_attendees ?? JSON.parse(existingMOM.ra_team_attendees || "[]")
      ),

      client_team_attendees: JSON.stringify(
        client_team_attendees ??
          JSON.parse(existingMOM.client_team_attendees || "[]")
      ),

      vendor_team_attendees: JSON.stringify(
        vendor_team_attendees ??
          JSON.parse(existingMOM.vendor_team_attendees || "[]")
      ),

      other_attendees: JSON.stringify(
        other_attendees ?? JSON.parse(existingMOM.other_attendees || "[]")
      ),

      minutes: JSON.stringify(
        minutes ?? JSON.parse(existingMOM.minutes || "[]")
      ),

      updated_at: new Date().toISOString(),
    };

    // ✅ Update Sheet
    await db.updateById("mom", id, updatedData);

    res.json({
      message: "MOM Updated Successfully",
      updated: updatedData,
    });
  } catch (err) {
    console.error("Edit MOM Error:", err);
    res.status(500).json({ message: "Error updating MOM" });
  }
};
