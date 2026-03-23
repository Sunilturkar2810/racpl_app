import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";
import { API_BASE_URL } from "../../config";

const API_URL = `${API_BASE_URL}/api/projects`;

export const fetchProjects = createAsyncThunk(
  "projects/fetchProjects",
  async (_, { getState, rejectWithValue }) => {
    const { token } = getState().auth;
    try {
      const response = await axios.get(`${API_URL}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data?.message || "Failed to fetch projects",
      );
    }
  },
);

export const createProject = createAsyncThunk(
  "projects/createProject",
  async (projectData, { getState, rejectWithValue }) => {
    const { token } = getState().auth;
    try {
      const response = await axios.post(API_URL, projectData, {
        headers: { Authorization: `Bearer ${token}` },
      });
      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data?.message || "Failed to create project",
      );
    }
  },
);

export const updateProject = createAsyncThunk(
  "projects/updateProject",
  async ({ id, updatedData }, { getState, rejectWithValue }) => {
    const { token } = getState().auth;
    try {
      const response = await axios.put(`${API_URL}/${id}`, updatedData, {
        headers: { Authorization: `Bearer ${token}` },
      });
      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data?.message || "Failed to update project",
      );
    }
  },
);

const projectsSlice = createSlice({
  name: "projects",
  initialState: {
    projects: [],
    isLoading: false,
    isSubmitting: false,
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      // Fetch
      .addCase(fetchProjects.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchProjects.fulfilled, (state, action) => {
        state.isLoading = false;
        state.projects = action.payload;
      })
      .addCase(fetchProjects.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      // Create
      .addCase(createProject.pending, (state) => {
        state.isSubmitting = true;
        state.error = null;
      })
      .addCase(createProject.fulfilled, (state, action) => {
        state.isSubmitting = false;
        state.projects = [action.payload.project, ...state.projects];
      })
      .addCase(createProject.rejected, (state, action) => {
        state.isSubmitting = false;
        state.error = action.payload;
      })
      // Update
      .addCase(updateProject.pending, (state) => {
        state.isSubmitting = true;
        state.error = null;
      })
      .addCase(updateProject.fulfilled, (state) => {
        state.isSubmitting = false;
        // The backend returns { message, updated }
        // We need the ID to update the list. The backend doesn't return the ID in 'updated'.
        // But we have the ID from the payload.
      })
      .addCase(updateProject.rejected, (state, action) => {
        state.isSubmitting = false;
        state.error = action.payload;
      });
  },
});

export default projectsSlice.reducer;
