import React, { useState, useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";
import MainLayout from "../../components/layout/MainLayout";
import Loader from "../../components/common/Loader";
import CreateProjectModal from "../../components/projects/CreateProjectModal";
import { fetchProjects } from "../../store/slices/projectsSlice";
import {
  LayoutGrid,
  List,
  Plus,
  Filter,
  Pencil,
  MapPin,
  User,
  Info,
  Calendar,
  IndianRupee,
  HardHat,
  UserCog,
} from "lucide-react";

/**
 * ✅ Projects Management Page
 */
const Projects = () => {
  const dispatch = useDispatch();
  const { projects = [], isLoading } = useSelector((state) => state.projects);

  const [viewMode, setViewMode] = useState("list");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [projectToEdit, setProjectToEdit] = useState(null);

  // Filters
  const [selectedProjectName, setSelectedProjectName] = useState("All");
  const [statusFilter, setStatusFilter] = useState("All");

  // Pagination
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 8;

  useEffect(() => {
    dispatch(fetchProjects());
  }, [dispatch]);

  const uniqueProjectNames = React.useMemo(() => {
    const names = projects
      .filter(Boolean)
      .map((p) => p.name)
      .filter(Boolean);
    return ["All", ...new Set(names)].sort();
  }, [projects]);

  const filteredProjects = projects.filter((proj) => {
    const matchesName =
      selectedProjectName === "All" || proj?.name === selectedProjectName;
    const matchesStatus =
      statusFilter === "All" || proj?.status === statusFilter;
    return matchesName && matchesStatus;
  });

  // Pagination Logic
  const totalPages = Math.ceil(filteredProjects.length / itemsPerPage);
  const paginatedProjects = filteredProjects.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage,
  );

  const handleEdit = (project) => {
    setProjectToEdit(project);
    setIsModalOpen(true);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case "Active":
        return "bg-emerald-500/10 text-emerald-500 border-emerald-500/20";
      case "On Hold":
        return "bg-amber-500/10 text-amber-500 border-amber-500/20";
      case "Completed":
        return "bg-sky-500/10 text-sky-500 border-sky-500/20";
      case "Cancelled":
        return "bg-rose-500/10 text-rose-500 border-rose-500/20";
      default:
        return "bg-slate-500/10 text-slate-500 border-slate-500/20";
    }
  };

  return (
    <MainLayout title="Project Management">
      <div className="p-4 md:p-8 space-y-6 max-w-[1600px] mx-auto min-h-[calc(100vh-80px)]">

        {/* ===============================
            ✅ Modern Toolbar
        =============================== */}
        <div className="flex flex-col xl:flex-row xl:items-center justify-between gap-4 bg-bg-card border border-border-main p-5 rounded-[2.5rem] shadow-sm backdrop-blur-md">

          {/* Filters Row */}
          <div className="flex flex-wrap items-end gap-4">
            {/* Project Name Filter */}
            <div className="space-y-1.5 flex-1 min-w-[160px]">
              <label className="text-[10px] font-black uppercase tracking-widest text-text-muted ml-1">
                Project Name
              </label>
              <div className="relative">
                <Filter
                  className="absolute left-4 top-1/2 -translate-y-1/2 text-primary"
                  size={14}
                />
                <select
                  value={selectedProjectName}
                  onChange={(e) => {
                    setSelectedProjectName(e.target.value);
                    setCurrentPage(1);
                  }}
                  className="w-full bg-bg-main border border-border-main rounded-2xl pl-10 pr-4 py-2.5 text-xs font-bold outline-none focus:border-primary transition-all cursor-pointer appearance-none"
                >
                  {uniqueProjectNames.map((name) => (
                    <option key={name} value={name}>
                      {name === "All" ? "All Projects" : name}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Status Filter */}
            <div className="space-y-1.5 flex-1 min-w-[140px]">
              <label className="text-[10px] font-black uppercase tracking-widest text-text-muted ml-1">
                Current Status
              </label>
              <div className="relative">
                <div className="absolute left-4 top-1/2 -translate-y-1/2 size-2 rounded-full bg-primary shadow-[0_0_8px_rgba(var(--primary-rgb),0.5)]" />
                <select
                  value={statusFilter}
                  onChange={(e) => {
                    setStatusFilter(e.target.value);
                    setCurrentPage(1);
                  }}
                  className="w-full bg-bg-main border border-border-main rounded-2xl pl-10 pr-4 py-2.5 text-xs font-bold outline-none focus:border-primary transition-all cursor-pointer appearance-none"
                >
                  <option value="All">Global Status</option>
                  <option value="Active">Active</option>
                  <option value="On Hold">On Hold</option>
                  <option value="Completed">Completed</option>
                  <option value="Cancelled">Cancelled</option>
                </select>
              </div>
            </div>
          </div>

          {/* Actions Row */}
          <div className="flex flex-wrap items-center gap-3 border-t xl:border-t-0 xl:border-l border-border-main pt-4 xl:pt-0 xl:pl-6 shrink-0">
            {/* View Toggle */}
            <div className="flex bg-bg-main gap-1 p-1 rounded-2xl border border-border-main shadow-inner">
              <button
                onClick={() => setViewMode("tiles")}
                className={`flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-bold transition-all ${viewMode === "tiles" ? "bg-bg-card shadow-md text-primary" : "text-text-muted hover:text-text-main"}`}
              >
                <LayoutGrid size={16} />
                <span className="hidden sm:inline">TILES</span>
              </button>
              <button
                onClick={() => setViewMode("list")}
                className={`flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-bold transition-all ${viewMode === "list" ? "bg-bg-card shadow-md text-primary" : "text-text-muted hover:text-text-main"}`}
              >
                <List size={16} />
                <span className="hidden sm:inline">LIST</span>
              </button>
            </div>

            {/* New Project Button */}
            <button
              onClick={() => {
                setProjectToEdit(null);
                setIsModalOpen(true);
              }}
              className="flex items-center justify-center gap-2 bg-primary text-white px-4 py-2.5 rounded-2xl text-xs font-bold shadow-xl shadow-primary/25 hover:shadow-primary/40 hover:-translate-y-0.5 transition-all active:scale-95 whitespace-nowrap"
            >
              <Plus size={18} strokeWidth={3} />
              <span>New Project</span>
            </button>
          </div>
        </div>

        {/* ===============================
            ✅ Optimized Content
        =============================== */}
        {isLoading ? (
          <div className="flex flex-col items-center justify-center py-32 gap-6 bg-bg-card rounded-4xl border border-border-main">
            <Loader className="w-16 h-16" />
            <div className="space-y-1 text-center font-bold">
              <p className="text-xl text-text-main">Syncing Records</p>
              <p className="text-sm text-text-muted animate-pulse">
                Refreshing your project database...
              </p>
            </div>
          </div>
        ) : paginatedProjects.length === 0 ? (
          <div className="bg-bg-card border-2 border-dashed border-border-main rounded-4xl py-32 text-center space-y-6">
            <div className="size-24 bg-bg-main rounded-full flex items-center justify-center mx-auto text-text-muted shadow-inner">
              <Info size={48} strokeWidth={1.5} />
            </div>
            <div className="space-y-2">
              <h3 className="text-2xl font-black text-text-main">
                No Records Matched
              </h3>
              <p className="text-sm text-text-muted font-medium max-w-xs mx-auto">
                We couldn't find any projects fitting these criteria. Try
                broadening your filter.
              </p>
            </div>
            <button
              onClick={() => {
                setSelectedProjectName("All");
                setStatusFilter("All");
              }}
              className="bg-primary/10 text-primary px-6 py-2.5 rounded-xl text-sm font-black hover:bg-primary/20 transition-all active:scale-95"
            >
              RESET FILTERS
            </button>
          </div>
        ) : viewMode === "tiles" ? (
          /* ===============================
              ✅ Premium Tiles View
          =============================== */
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {paginatedProjects.map((proj) => (
              <div
                key={proj.id}
                className="group bg-bg-card border border-border-main rounded-4xl p-6 pt-8 hover:shadow-2xl hover:shadow-primary/10 transition-all duration-500 relative flex flex-col h-full border-b-4 border-b-transparent hover:border-b-primary"
              >
                {/* Visual Accent */}
                <div className="absolute top-0 left-12 right-12 h-1 bg-gradient-to-r from-transparent via-primary/20 to-transparent group-hover:via-primary/50 transition-all" />

                <div className="flex justify-between items-start mb-6">
                  <span
                    className={`px-4 py-1.5 rounded-2xl text-[10px] font-black uppercase border tracking-widest shadow-sm ${getStatusColor(proj.status)}`}
                  >
                    {proj.status}
                  </span>
                  <button
                    onClick={() => handleEdit(proj)}
                    className="p-2.5 rounded-2xl bg-bg-main text-text-muted hover:text-white hover:bg-amber-500 transition-all hover:rotate-12"
                  >
                    <Pencil size={16} />
                  </button>
                </div>

                <div className="flex-1 space-y-2">
                  <h3 className="text-lg font-black text-text-main group-hover:text-primary transition-colors leading-tight line-clamp-2">
                    {proj.name}
                  </h3>
                  <p className="text-xs text-text-muted font-medium leading-relaxed line-clamp-2 group-hover:text-text-main transition-colors">
                    {proj.description ||
                      "Establish strategic milestones and track deliverables in real-time."}
                  </p>
                </div>

                <div className="mt-3 pt-3 border-t border-border-main/50 flex flex-col gap-3">
                  {/* Row 1: Client + Location */}
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="size-7 bg-bg-main rounded-lg flex items-center justify-center text-primary border border-border-main shadow-sm">
                        <User size={13} strokeWidth={2.5} />
                      </div>
                      <div className="flex flex-col">
                        <span className="text-[9px] font-black uppercase tracking-tighter text-text-muted">
                          Client
                        </span>
                        <span className="text-xs font-bold text-text-main truncate max-w-[90px]">
                          {proj.client_name || "—"}
                        </span>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="size-7 bg-bg-main rounded-lg flex items-center justify-center text-primary border border-border-main shadow-sm">
                        <MapPin size={13} strokeWidth={2.5} />
                      </div>
                      <div className="flex flex-col">
                        <span className="text-[9px] font-black uppercase tracking-tighter text-text-muted">
                          Location
                        </span>
                        <span className="text-xs font-bold text-text-main truncate max-w-[80px]">
                          {proj.location || "—"}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Row 2: Budget */}
                  {proj.budget && (
                    <div className="flex items-center gap-2">
                      <div className="size-7 bg-bg-main rounded-lg flex items-center justify-center text-amber-500 border border-border-main shadow-sm">
                        <IndianRupee size={13} strokeWidth={2.5} />
                      </div>
                      <div className="flex flex-col">
                        <span className="text-[9px] font-black uppercase tracking-tighter text-text-muted">
                          Budget
                        </span>
                        <span className="text-xs font-bold text-text-main">
                          ₹{Number(proj.budget).toLocaleString("en-IN")}
                        </span>
                      </div>
                    </div>
                  )}

                  {/* Row 3: Project Manager + Contractor */}
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="size-7 bg-bg-main rounded-lg flex items-center justify-center text-sky-500 border border-border-main shadow-sm">
                        <UserCog size={13} strokeWidth={2.5} />
                      </div>
                      <div className="flex flex-col">
                        <span className="text-[9px] font-black uppercase tracking-tighter text-text-muted">
                          Manager
                        </span>
                        <span className="text-xs font-bold text-text-main truncate max-w-[80px]">
                          {proj.project_manager || "—"}
                        </span>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="size-7 bg-bg-main rounded-lg flex items-center justify-center text-violet-500 border border-border-main shadow-sm">
                        <HardHat size={13} strokeWidth={2.5} />
                      </div>
                      <div className="flex flex-col">
                        <span className="text-[9px] font-black uppercase tracking-tighter text-text-muted">
                          Contractor
                        </span>
                        <span className="text-xs font-bold text-text-main truncate max-w-[80px]">
                          {proj.contractor || "—"}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          /* ===============================
              ✅ Polished List View
          =============================== */
          <div className="bg-bg-card border border-border-main rounded-4xl overflow-hidden shadow-xl shadow-black/5">
            <div className="overflow-x-auto">
              <table className="w-full text-sm min-w-[700px]">
                <thead>
                  <tr className="bg-bg-main/30 border-b border-border-main">
                    <th className="px-6 py-5 text-left text-[10px] font-black uppercase tracking-widest text-text-muted">
                      Project
                    </th>
                    <th className="px-6 py-5 text-left text-[10px] font-black uppercase tracking-widest text-text-muted">
                      Client
                    </th>
                    <th className="px-6 py-5 text-left text-[10px] font-black uppercase tracking-widest text-text-muted">
                      Location
                    </th>
                    <th className="px-6 py-5 text-left text-[10px] font-black uppercase tracking-widest text-text-muted">
                      Budget
                    </th>
                    <th className="px-6 py-5 text-left text-[10px] font-black uppercase tracking-widest text-text-muted">
                      Manager
                    </th>
                    <th className="px-6 py-5 text-left text-[10px] font-black uppercase tracking-widest text-text-muted">
                      Contractor
                    </th>
                    <th className="px-6 py-5 text-left text-[10px] font-black uppercase tracking-widest text-text-muted text-center">
                      Status
                    </th>
                    <th className="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-text-muted text-center">
                      Edit
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border-main/50">
                  {paginatedProjects.map((proj) => (
                    <tr
                      key={proj.id}
                      className="hover:bg-bg-main/30 transition-all group"
                    >
                      <td className="px-6 py-4">
                        <div className="font-extrabold text-text-main group-hover:text-primary transition-colors text-sm">
                          {proj.name}
                        </div>
                        <div className="text-[11px] text-text-muted mt-0.5 font-medium line-clamp-1 max-w-xs">
                          {proj.description || "—"}
                        </div>
                      </td>
                      <td className="px-6 py-4 text-text-muted font-bold text-xs whitespace-nowrap">
                        {proj.client_name || "—"}
                      </td>
                      <td className="px-6 py-4 text-text-muted font-bold text-xs">
                        <div className="flex items-center gap-1.5">
                          <MapPin size={12} className="text-primary shrink-0" />
                          <span className="truncate max-w-[100px]">
                            {proj.location || "—"}
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-text-muted font-bold text-xs whitespace-nowrap">
                        {proj.budget
                          ? `₹${Number(proj.budget).toLocaleString("en-IN")}`
                          : "—"}
                      </td>
                      <td className="px-6 py-4 text-text-muted font-bold text-xs whitespace-nowrap">
                        {proj.project_manager || "—"}
                      </td>
                      <td className="px-6 py-4 text-text-muted font-bold text-xs whitespace-nowrap">
                        {proj.contractor || "—"}
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span
                          className={`px-3 py-1.5 rounded-xl text-[9px] font-black uppercase border tracking-widest inline-block ${getStatusColor(proj.status)}`}
                        >
                          {proj.status}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex justify-center">
                          <button
                            onClick={() => handleEdit(proj)}
                            className="size-9 rounded-xl flex items-center justify-center text-amber-500 hover:bg-amber-500/10 transition-all active:scale-90"
                          >
                            <Pencil size={18} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* ===============================
            ✅ Pagination
        =============================== */}
        {!isLoading && totalPages > 1 && (
          <div className="flex flex-wrap justify-between items-center gap-3 px-5 py-3 border border-border-main bg-bg-card rounded-2xl text-xs mt-2">
            <p className="text-text-muted font-bold">
              Showing {(currentPage - 1) * itemsPerPage + 1}–
              {Math.min(currentPage * itemsPerPage, filteredProjects.length)} of{" "}
              {filteredProjects.length}
            </p>
            <div className="flex gap-2 items-center">
              <button
                disabled={currentPage === 1}
                onClick={() => setCurrentPage((p) => p - 1)}
                className="px-3 py-1 rounded-lg border disabled:opacity-40 font-bold hover:bg-bg-main transition-all"
              >
                Prev
              </button>
              <span className="px-3 py-1 rounded-lg bg-primary text-white border border-border-main font-bold">
                {currentPage}
              </span>
              <button
                disabled={currentPage === totalPages}
                onClick={() => setCurrentPage((p) => p + 1)}
                className="px-3 py-1 rounded-lg border disabled:opacity-40 font-bold hover:bg-bg-main transition-all"
              >
                Next
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Create/Edit Modal */}
      <CreateProjectModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        projectToEdit={projectToEdit}
        onSuccess={() => dispatch(fetchProjects())}
      />
    </MainLayout>
  );
};

export default Projects;
