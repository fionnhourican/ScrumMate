import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { entriesService } from '../../services/entriesService';

interface DailyEntry {
  id: string;
  entryDate: string;
  yesterdayWork: string;
  todayPlan: string;
  blockers: string;
  createdAt: string;
  updatedAt: string;
}

interface EntriesState {
  entries: DailyEntry[];
  currentEntry: DailyEntry | null;
  isLoading: boolean;
  error: string | null;
}

const initialState: EntriesState = {
  entries: [],
  currentEntry: null,
  isLoading: false,
  error: null,
};

export const fetchEntries = createAsyncThunk('entries/fetchEntries', async () => {
  return await entriesService.getEntries();
});

export const createEntry = createAsyncThunk(
  'entries/createEntry',
  async (entry: Omit<DailyEntry, 'id' | 'createdAt' | 'updatedAt'>) => {
    return await entriesService.createEntry(entry);
  }
);

export const updateEntry = createAsyncThunk(
  'entries/updateEntry',
  async ({ id, entry }: { id: string; entry: Partial<DailyEntry> }) => {
    return await entriesService.updateEntry(id, entry);
  }
);

export const deleteEntry = createAsyncThunk('entries/deleteEntry', async (id: string) => {
  await entriesService.deleteEntry(id);
  return id;
});

const entriesSlice = createSlice({
  name: 'entries',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchEntries.fulfilled, (state, action) => {
        state.entries = action.payload;
        state.isLoading = false;
      })
      .addCase(createEntry.fulfilled, (state, action) => {
        state.entries.unshift(action.payload);
        state.isLoading = false;
      })
      .addCase(updateEntry.fulfilled, (state, action) => {
        const index = state.entries.findIndex(e => e.id === action.payload.id);
        if (index !== -1) {
          state.entries[index] = action.payload;
        }
        state.isLoading = false;
      })
      .addCase(deleteEntry.fulfilled, (state, action) => {
        state.entries = state.entries.filter(e => e.id !== action.payload);
        state.isLoading = false;
      });
  },
});

export const { clearError } = entriesSlice.actions;
export default entriesSlice.reducer;
