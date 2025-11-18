import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  Typography,
  Button,
  Card,
  CardContent,
  Box,
  Grid,
  Tabs,
  Tab,
} from '@mui/material';
import {
  fetchWeeklySummaries,
  fetchMonthlyReports,
  generateWeeklySummary,
  generateMonthlyReport,
} from '../store/slices/summariesSlice';
import { RootState, AppDispatch } from '../store/store';

const ReportsPage: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { weeklySummaries, monthlyReports, isLoading } = useSelector(
    (state: RootState) => state.summaries
  );
  const [tabValue, setTabValue] = React.useState(0);

  useEffect(() => {
    dispatch(fetchWeeklySummaries());
    dispatch(fetchMonthlyReports());
  }, [dispatch]);

  const handleGenerateWeekly = () => {
    const today = new Date();
    const monday = new Date(today.setDate(today.getDate() - today.getDay() + 1));
    const weekStart = monday.toISOString().split('T')[0];
    dispatch(generateWeeklySummary(weekStart));
  };

  const handleGenerateMonthly = () => {
    const now = new Date();
    dispatch(generateMonthlyReport({ 
      month: now.getMonth() + 1, 
      year: now.getFullYear() 
    }));
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Reports
      </Typography>

      <Tabs value={tabValue} onChange={(_, newValue) => setTabValue(newValue)} sx={{ mb: 3 }}>
        <Tab label="Weekly Summaries" />
        <Tab label="Monthly Reports" />
      </Tabs>

      {tabValue === 0 && (
        <Box>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
            <Typography variant="h5">Weekly Summaries</Typography>
            <Button variant="contained" onClick={handleGenerateWeekly}>
              Generate This Week
            </Button>
          </Box>

          <Grid container spacing={2}>
            {weeklySummaries.map((summary) => (
              <Grid item xs={12} key={summary.id}>
                <Card>
                  <CardContent>
                    <Typography variant="h6" gutterBottom>
                      Week of {summary.weekStart} to {summary.weekEnd}
                    </Typography>
                    <Typography variant="body2" color="text.secondary" gutterBottom>
                      Generated: {new Date(summary.generatedAt).toLocaleDateString()}
                    </Typography>
                    <Typography variant="body1" sx={{ whiteSpace: 'pre-wrap' }}>
                      {summary.summaryText}
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </Box>
      )}

      {tabValue === 1 && (
        <Box>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
            <Typography variant="h5">Monthly Reports</Typography>
            <Button variant="contained" onClick={handleGenerateMonthly}>
              Generate This Month
            </Button>
          </Box>

          <Grid container spacing={2}>
            {monthlyReports.map((report) => (
              <Grid item xs={12} key={report.id}>
                <Card>
                  <CardContent>
                    <Typography variant="h6" gutterBottom>
                      {new Date(report.year, report.month - 1).toLocaleDateString('en-US', {
                        month: 'long',
                        year: 'numeric',
                      })}
                    </Typography>
                    <Typography variant="body2" color="text.secondary" gutterBottom>
                      Generated: {new Date(report.generatedAt).toLocaleDateString()}
                    </Typography>
                    <Typography variant="body1">
                      Total Weeks: {report.reportData?.totalWeeks || 0}
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </Box>
      )}
    </Box>
  );
};

export default ReportsPage;
