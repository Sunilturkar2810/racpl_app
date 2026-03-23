const db = require("../config/db.config");

/* ===========================================
   ✅ GET ALL PROJECTS
=========================================== */
exports.getAllProjects = async (req, res) => {
  try {
    const projects = await db.getAll("projects");

    const result = projects
      .filter((p) => p.id)
      .map((p) => ({
        ...p,
        id: Number(p.id),
      }))
      .sort((a, b) => b.id - a.id);

    const { role, email, name: userName } = req.user;
    let filteredResult = result;

    if (role !== "Admin" && role !== "SuperAdmin") {
      filteredResult = result.filter(
        (p) =>
          p.project_manager === email ||
          (userName && p.project_manager === userName)
      );
    }

    res.json(filteredResult);
  } catch (err) {
    console.error("Project Fetch Error:", err);
    res.status(500).json({ message: "Error fetching projects" });
  }
};

/* ===========================================
   ✅ CREATE PROJECT
=========================================== */
exports.createProject = async (req, res) => {
  try {
    const { name, location, client_name, status, description, start_date, end_date, budget, project_manager, contractor } = req.body;

    if (!name) {
      return res.status(400).json({ message: "Project name is required" });
    }

    const allProjects = await db.getAll("projects");
    const nextId =
      allProjects.length > 0
        ? Math.max(...allProjects.map((p) => Number(p.id) || 0)) + 1
        : 1;

    const projectData = {
      id: nextId,
      name,
      location: location || "N/A",
      client_name: client_name || "N/A",
      status: status || "Active",
      description: description || "",
      start_date: start_date || "",
      end_date: end_date || "",
      budget: budget || "",
      project_manager: project_manager || "",
      contractor: contractor || "",
      created_at: new Date().toISOString(),
    };

    await db.insertByHeader("projects", projectData);

    res.status(201).json({
      message: "✅ Project Created Successfully",
      project: projectData,
    });
  } catch (err) {
    console.error("Project Create Error:", err);
    res.status(500).json({ message: err.message });
  }
};

/* ===========================================
   ✅ EDIT PROJECT
=========================================== */
exports.editProject = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, location, client_name, status, description, start_date, end_date, budget, project_manager, contractor } = req.body;

    const projects = await db.getAll("projects");
    const existingProject = projects.find(
      (p) => String(p.id).trim() === String(id).trim()
    );

    if (!existingProject) {
      return res.status(404).json({ message: "Project not found" });
    }

    const updatedData = {
      name: name || existingProject.name,
      location: location || existingProject.location,
      client_name: client_name || existingProject.client_name,
      status: status || existingProject.status,
      description: description || existingProject.description,
      start_date: start_date !== undefined ? start_date : (existingProject.start_date || ""),
      end_date: end_date !== undefined ? end_date : (existingProject.end_date || ""),
      budget: budget !== undefined ? budget : (existingProject.budget || ""),
      project_manager: project_manager !== undefined ? project_manager : (existingProject.project_manager || ""),
      contractor: contractor !== undefined ? contractor : (existingProject.contractor || ""),
      // created_at stays same
    };

    await db.updateById("projects", id, updatedData);

    res.json({
      message: "✅ Project Updated Successfully",
      updated: updatedData,
    });
  } catch (err) {
    console.error("Project Edit Error:", err);
    res.status(500).json({ message: "Error updating project" });
  }
};
