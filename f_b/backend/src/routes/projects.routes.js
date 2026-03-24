const express = require("express");
const router = express.Router();
const projectController = require("../controllers/projects.controller");
const { verifyToken } = require('../middlewares/auth.middleware');
const multer = require("multer");
const upload = multer({ storage: multer.memoryStorage() });

// Get All Projects
router.get("/", verifyToken, projectController.getAllProjects);

// Create Project
const uploadFields = upload.fields([
  { name: "award_letter", maxCount: 1 },
  { name: "land_paper_zonning", maxCount: 1 },
  { name: "water_testing", maxCount: 1 },
  { name: "plot_demarcation_by_govt", maxCount: 1 },
  { name: "dpc_certificate", maxCount: 1 },
  { name: "soil_testing", maxCount: 1 },
]);
router.post("/", verifyToken, uploadFields, projectController.createProject);

// Edit Project
router.put("/:id", verifyToken, uploadFields, projectController.editProject);

module.exports = router;
