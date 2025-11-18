import { configureStore } from '@reduxjs/toolkit';
import authSlice from './slices/authSlice';
import entriesSlice from './slices/entriesSlice';
import summariesSlice from './slices/summariesSlice';

export const store = configureStore({
  reducer: {
    auth: authSlice,
    entries: entriesSlice,
    summaries: summariesSlice,
  },
  devTools: process.env.NODE_ENV !== 'production',
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
