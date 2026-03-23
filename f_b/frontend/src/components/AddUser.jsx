import React, { useState } from "react";
import axios from "axios";
import { useSelector } from "react-redux";
import toast from "react-hot-toast";
import { API_BASE_URL } from "../config";

const AddUser = () => {
  const { token } = useSelector((state) => state.auth);
  const [formData, setFormData] = useState({
    First_Name: "",
    Last_Name: "",
    Work_Email: "",
    Password: "",
    Role: "Employee",
    Designation: "",
    Department: "",
    Joining_Date: "",
  });
  const [isLoading, setIsLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      const response = await axios.post(
        `${API_BASE_URL}/api/auth/register`,
        formData,
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );

      toast.success(response.data.message || "User added successfully!");
      setFormData({
        First_Name: "",
        Last_Name: "",
        Work_Email: "",
        Password: "",
        Role: "Employee",
        Designation: "",
        Department: "",
        Joining_Date: "",
      });
    } catch (error) {
      toast.error(
        error.response?.data?.message || error.message || "Failed to add user"
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="max-w-2xl">
      <div>
        <h3 className="text-lg font-bold text-text-main mb-1">Add User</h3>
        <p className="text-text-muted text-sm pb-4 border-b border-border-main mb-6">
          Register a new employee/user dynamically.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-5">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="grid gap-1">
            <label className="text-sm font-bold text-text-main">
              First Name *
            </label>
            <input
              type="text"
              name="First_Name"
              value={formData.First_Name}
              onChange={handleChange}
              required
              className="px-4 py-2 bg-bg-main border border-border-main rounded-lg outline-none focus:border-primary"
            />
          </div>
          <div className="grid gap-1">
            <label className="text-sm font-bold text-text-main">
              Last Name *
            </label>
            <input
              type="text"
              name="Last_Name"
              value={formData.Last_Name}
              onChange={handleChange}
              required
              className="px-4 py-2 bg-bg-main border border-border-main rounded-lg outline-none focus:border-primary"
            />
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="grid gap-1">
            <label className="text-sm font-bold text-text-main">
              Work Email *
            </label>
            <input
              type="email"
              name="Work_Email"
              value={formData.Work_Email}
              onChange={handleChange}
              required
              className="px-4 py-2 bg-bg-main border border-border-main rounded-lg outline-none focus:border-primary"
            />
          </div>
          <div className="grid gap-1">
            <label className="text-sm font-bold text-text-main">
              Password *
            </label>
            <input
              type="password"
              name="Password"
              value={formData.Password}
              onChange={handleChange}
              required
              className="px-4 py-2 bg-bg-main border border-border-main rounded-lg outline-none focus:border-primary"
            />
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="grid gap-1">
            <label className="text-sm font-bold text-text-main">Role</label>
            <select
              name="Role"
              value={formData.Role}
              onChange={handleChange}
              className="px-4 py-2 bg-bg-main border border-border-main rounded-lg outline-none focus:border-primary"
            >
              <option value="Employee">Employee</option>
              <option value="Admin">Admin</option>
              <option value="SuperAdmin">SuperAdmin</option>
              <option value="PC">PC</option>
            </select>
          </div>
          <div className="grid gap-1">
            <label className="text-sm font-bold text-text-main">
              Designation
            </label>
            <input
              type="text"
              name="Designation"
              value={formData.Designation}
              onChange={handleChange}
              className="px-4 py-2 bg-bg-main border border-border-main rounded-lg outline-none focus:border-primary"
            />
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="grid gap-1">
            <label className="text-sm font-bold text-text-main">
              Department
            </label>
            <input
              type="text"
              name="Department"
              value={formData.Department}
              onChange={handleChange}
              className="px-4 py-2 bg-bg-main border border-border-main rounded-lg outline-none focus:border-primary"
            />
          </div>
          <div className="grid gap-1">
            <label className="text-sm font-bold text-text-main">
              Joining Date
            </label>
            <input
              type="date"
              name="Joining_Date"
              value={formData.Joining_Date}
              onChange={handleChange}
              className="px-4 py-2 bg-bg-main border border-border-main rounded-lg outline-none focus:border-primary"
            />
          </div>
        </div>

        <div className="flex justify-end pt-4">
          <button
            type="submit"
            disabled={isLoading}
            className="bg-primary text-white px-6 py-2 rounded-lg font-bold disabled:opacity-50 hover:bg-primary/90 transition-colors"
          >
            {isLoading ? "Saving..." : "Add User"}
          </button>
        </div>
      </form>
    </div>
  );
};

export default AddUser;
