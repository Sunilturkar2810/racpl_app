const db = require("../config/db.config");
const { uploadToDrive } = require("../utils/googleDrive");

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
        client_name: p.client_name === "N/A" ? "" : p.client_name,
        contact_no: p.contact_no === "N/A" ? "" : p.contact_no,
      }))
      .sort((a, b) => b.id - a.id);

    const { role, email, name: userName } = req.user;
    let filteredResult = result;

    if (role !== "Admin" && role !== "SuperAdmin") {
      filteredResult = result.filter(
        (p) =>
          p.team_lead === email ||
          (userName && p.team_lead === userName)
      );
    }

    res.json(filteredResult);
  } catch (err) {
    console.error("Project Fetch Error:", err);
    res.status(500).json({ message: "Error fetching projects" });
  }
};

/* ===========================================
   GET PROJECT BY ID
=========================================== */
exports.getProjectById = async (req, res) => {
  try {
    const { id } = req.params;
    const projects = await db.getAll("projects");
    const project = projects.find(
      (p) => String(p.id).trim() === String(id).trim(),
    );

    if (!project) {
      return res.status(404).json({ message: "Project not found" });
    }

    const normalizedProject = {
      ...project,
      id: Number(project.id),
      client_name: project.client_name === "N/A" ? "" : project.client_name,
      contact_no: project.contact_no === "N/A" ? "" : project.contact_no,
    };

    res.json(normalizedProject);
  } catch (err) {
    console.error("Project Detail Error:", err);
    res.status(500).json({ message: "Error fetching project" });
  }
};

/* ===========================================
   ✅ CREATE PROJECT
=========================================== */
exports.createProject = async (req, res) => {
  try {
    const { id, name } = req.body;

    if (!name) {
      return res.status(400).json({ message: "Project name is required" });
    }

    let finalId = id;
    if (!finalId) {
      const allProjects = await db.getAll("projects");
      finalId =
        allProjects.length > 0
          ? Math.max(...allProjects.map((p) => Number(p.id) || 0)) + 1
          : 1;
    }

    const formatMultiFields = (data) => {
      if (Array.isArray(data.client_name)) {
        data.client_name = data.client_name.map(n => n.trim() || "N/A").join("\n");
      }
      if (Array.isArray(data.contact_no)) {
        data.contact_no = data.contact_no.map(c => c.trim() || "N/A").join("\n");
      }
    };

    const projectData = {
      ...req.body,
      id: finalId,
      created_at: new Date().toISOString(),
    };

    formatMultiFields(projectData);

    // Handle file uploads (if any attached at creation)
    if (req.files) {
      const fileFields = [
        "award_letter",
        "land_paper_zonning",
        "water_testing",
        "plot_demarcation_by_govt",
        "dpc_certificate",
        "soil_testing",
      ];
      for (const field of fileFields) {
        if (req.files[field] && req.files[field][0]) {
          const file = req.files[field][0];
          const fileUrl = await uploadToDrive(
            file.buffer,
            file.originalname,
            file.mimetype
          );
          projectData[field] = fileUrl;
        }
      }
    }

    // Ensure common defaults for new projects
    if (!projectData.status) projectData.status = "Award to Start";
    if (!projectData.address) projectData.address = "N/A";
    if (!projectData.location) projectData.location = "N/A";
    if (!projectData.client_name) projectData.client_name = "N/A";
    if (!projectData.contact_no) projectData.contact_no = "N/A";

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
    
    const projects = await db.getAll("projects");
    const existingProject = projects.find(
      (p) => String(p.id).trim() === String(id).trim()
    );

    if (!existingProject) {
      return res.status(404).json({ message: "Project not found" });
    }

    const updatedData = { ...req.body };

    // Format multi-client fields if sent as arrays
    if (Array.isArray(updatedData.client_name)) {
      updatedData.client_name = updatedData.client_name.map(n => n.trim() || "N/A").join("\n");
    }
    if (Array.isArray(updatedData.contact_no)) {
      updatedData.contact_no = updatedData.contact_no.map(c => c.trim() || "N/A").join("\n");
    }

    // Handle File Uploads
    if (req.files) {
      const uploadFields = [
        "award_letter",
        "land_paper_zonning",
        "water_testing",
        "plot_demarcation_by_govt",
        "dpc_certificate",
        "soil_testing",
      ];

      for (const field of uploadFields) {
        if (req.files[field] && req.files[field][0]) {
          const file = req.files[field][0];
          const fileUrl = await uploadToDrive(
            file.buffer,
            file.originalname,
            file.mimetype
          );
          updatedData[field] = fileUrl;
        }
      }
    }

    const mergedProject = {
      ...existingProject,
      ...updatedData,
      id: Number(id),
      client_name:
        (updatedData.client_name ?? existingProject.client_name) === "N/A"
          ? ""
          : updatedData.client_name ?? existingProject.client_name,
      contact_no:
        (updatedData.contact_no ?? existingProject.contact_no) === "N/A"
          ? ""
          : updatedData.contact_no ?? existingProject.contact_no,
    };

    await db.updateById("projects", id, updatedData);

    res.json({
      message: "✅ Project Updated Successfully",
      updated: mergedProject,
    });
  } catch (err) {
    console.error("Project Edit Error:", err);
    res.status(500).json({ message: "Error updating project" });
  }
};

