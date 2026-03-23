const express = require("express");
const router = express.Router();
const projectController = require("../controllers/projects.controller");
const { verifyToken } = require('../middlewares/auth.middleware');

// Get All Projects
router.get("/", verifyToken, projectController.getAllProjects);

// Create Project
router.post("/", verifyToken, projectController.createProject);

// Edit Project
router.put("/:id", verifyToken, projectController.editProject);

module.exports = router;
