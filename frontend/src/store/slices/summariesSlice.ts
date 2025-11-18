import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { summariesService } from '../../services/summariesService';

interface WeeklySummary {
  id: string;
  weekStart: string;
  weekEnd: string;
  summaryText: string;
  generatedAt: string;
}

interface MonthlyReport {
  id: string;
  month: number;
  year: number;
  reportData: any;
  generatedAt: string;
}

interface SummariesState {
  weeklySummaries: WeeklySummary[];
  monthlyReports: MonthlyReport[];
  isLoading: boolean;
  error: string | null;
}

const initialState: SummariesState = {
  weeklySummaries: [],
  monthlyReports: [],
  isLoading: false,
  error: null,
};

export const fetchWeeklySummaries = createAsyncThunk(
  'summaries/fetchWeeklySummaries',
  async () => {
    return await summariesService.getWeeklySummaries();
  }
);

export const generateWeeklySummary = createAsyncThunk(
  'summaries/generateWeeklySummary',
  async (weekStart: string) => {
    return await summariesService.generateWeeklySummary(weekStart);
  }
);

export const fetchMonthlyReports = createAsyncThunk(
  'summaries/fetchMonthlyReports',
  async () => {
    return await summariesService.getMonthlyReports();
  }
);

export const generateMonthlyReport = createAsyncThunk(
  'summaries/generateMonthlyReport',
  async ({ month, year }: { month: number; year: number }) => {
    return await summariesService.generateMonthlyReport(month, year);
  }
);

const summariesSlice = createSlice({
  name: 'summaries',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchWeeklySummaries.fulfilled, (state, action) => {
        state.weeklySummaries = action.payload;
        state.isLoading = false;
      })
      .addCase(generateWeeklySummary.fulfilled, (state, action) => {
        state.weeklySummaries.unshift(action.payload);
        state.isLoading = false;
      })
      .addCase(fetchMonthlyReports.fulfilled, (state, action) => {
        state.monthlyReports = action.payload;
        state.isLoading = false;
      })
      .addCase(generateMonthlyReport.fulfilled, (state, action) => {
        state.monthlyReports.unshift(action.payload);
        state.isLoading = false;
      });
  },
});

export const { clearError } = summariesSlice.actions;
export default summariesSlice.reducer;
