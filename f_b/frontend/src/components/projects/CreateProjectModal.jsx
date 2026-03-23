import React, { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import toast from "react-hot-toast";
import { createProject, updateProject } from "../../store/slices/projectsSlice";

const Input = ({ label, ...props }) => (
  <div className="flex flex-col gap-1">
    <label className="text-[11px] font-bold uppercase text-text-muted">
      {label}
    </label>
    <input
      {...props}
      className="w-full bg-bg-main border border-border-main rounded-xl px-4 py-2.5 text-sm focus:border-primary outline-none transition-colors"
    />
  </div>
);

const Select = ({ label, children, ...props }) => (
  <div className="flex flex-col gap-1">
    <label className="text-[11px] font-bold uppercase text-text-muted">
      {label}
    </label>
    <select
      {...props}
      className="w-full bg-bg-main border border-border-main rounded-xl px-4 py-2.5 text-sm focus:border-primary outline-none transition-colors cursor-pointer"
    >
      {children}
    </select>
  </div>
);

const CreateProjectModal = ({ isOpen, onClose, projectToEdit, onSuccess }) => {
  const dispatch = useDispatch();
  const { isSubmitting } = useSelector((state) => state.projects);

  const [formData, setFormData] = useState({
    name: "",
    client_name: "",
    location: "",
    description: "",
    status: "Active",
    start_date: "",
    end_date: "",
    budget: "",
    project_manager: "",
    contractor: "",
  });

  useEffect(() => {
    if (projectToEdit && isOpen) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setFormData({
        name: projectToEdit.name || "",
        client_name: projectToEdit.client_name || "",
        location: projectToEdit.location || "",
        description: projectToEdit.description || "",
        status: projectToEdit.status || "Active",
        start_date: projectToEdit.start_date || "",
        end_date: projectToEdit.end_date || "",
        budget: projectToEdit.budget || "",
        project_manager: projectToEdit.project_manager || "",
        contractor: projectToEdit.contractor || "",
      });
    } else if (isOpen) {
      setFormData({
        name: "",
        client_name: "",
        location: "",
        description: "",
        status: "Active",
        start_date: "",
        end_date: "",
        budget: "",
        project_manager: "",
        contractor: "",
      });
    }
  }, [projectToEdit, isOpen]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name) {
      return toast.error("Project Name is required");
    }

    try {
      if (projectToEdit) {
        await dispatch(updateProject({ id: projectToEdit.id, updatedData: formData })).unwrap();
        toast.success("Project updated successfully");
      } else {
        await dispatch(createProject(formData)).unwrap();
        toast.success("Project created successfully");
      }
      onSuccess();
      onClose();
    } catch (error) {
      toast.error(error || "Something went wrong");
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-bg-card w-full max-w-3xl rounded-3xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-200">
        {/* Header */}
        <div className="px-8 py-6 border-b border-border-main flex justify-between items-center bg-bg-main/20">
          <div>
            <h2 className="text-xl font-bold text-text-main">
              {projectToEdit ? "Edit Project" : "Create New Project"}
            </h2>
            <p className="text-xs text-text-muted mt-1">
              Enter the project details below
            </p>
          </div>
          <button
            onClick={onClose}
            className="size-10 rounded-full hover:bg-bg-main flex items-center justify-center text-text-muted transition-colors"
          >
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-8 space-y-5 max-h-[80vh] overflow-y-auto">
          {/* Row 1: Project Name (full width) */}
          <Input
            label="Project Name *"
            placeholder="e.g. Smart City Phase 1"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            required
          />

          {/* Row 2: Client Name + Location */}
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Client Name"
              placeholder="Client Name"
              value={formData.client_name}
              onChange={(e) => setFormData({ ...formData, client_name: e.target.value })}
            />
            <Input
              label="Location"
              placeholder="Project Location"
              value={formData.location}
              onChange={(e) => setFormData({ ...formData, location: e.target.value })}
            />
          </div>

          {/* Row 3: Start Date + End Date */}
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Start Date"
              type="date"
              value={formData.start_date}
              onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
            />
            <Input
              label="End Date"
              type="date"
              value={formData.end_date}
              onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
            />
          </div>

          {/* Row 4: Budget + Status */}
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Budget (₹)"
              type="number"
              placeholder="e.g. 5000000"
              value={formData.budget}
              onChange={(e) => setFormData({ ...formData, budget: e.target.value })}
            />
            <Select
              label="Status"
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value })}
            >
              <option value="Active">Active</option>
              <option value="On Hold">On Hold</option>
              <option value="Completed">Completed</option>
              <option value="Cancelled">Cancelled</option>
            </Select>
          </div>

          {/* Row 5: Project Manager + Contractor */}
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Project Manager"
              placeholder="Manager Name"
              value={formData.project_manager}
              onChange={(e) => setFormData({ ...formData, project_manager: e.target.value })}
            />
            <Input
              label="Contractor"
              placeholder="Contractor Name"
              value={formData.contractor}
              onChange={(e) => setFormData({ ...formData, contractor: e.target.value })}
            />
          </div>

          {/* Row 6: Description (full width) */}
          <div className="flex flex-col gap-1">
            <label className="text-[11px] font-bold uppercase text-text-muted">
              Description
            </label>
            <textarea
              rows="3"
              placeholder="Brief description of the project"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              className="w-full bg-bg-main border border-border-main rounded-xl px-4 py-2.5 text-sm focus:border-primary outline-none transition-colors resize-none"
            />
          </div>

          <div className="flex gap-4 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-3 px-6 rounded-xl font-bold bg-bg-main text-text-main hover:bg-border-main transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="flex-1 py-3 px-6 rounded-xl font-bold bg-primary text-white hover:opacity-90 transition-opacity disabled:opacity-50 shadow-lg shadow-primary/20"
            >
              {isSubmitting ? "Saving..." : projectToEdit ? "Update Project" : "Create Project"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default CreateProjectModal;
