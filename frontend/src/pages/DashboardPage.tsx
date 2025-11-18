import React from 'react';
import { Typography, Grid, Card, CardContent, Button, Box } from '@mui/material';
import { useNavigate } from 'react-router-dom';

const DashboardPage: React.FC = () => {
  const navigate = useNavigate();

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Dashboard
      </Typography>
      
      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Daily Entries
              </Typography>
              <Typography variant="body2" color="text.secondary" paragraph>
                Track your daily accomplishments, plans, and blockers.
              </Typography>
              <Button 
                variant="contained" 
                onClick={() => navigate('/entries')}
              >
                Manage Entries
              </Button>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Reports
              </Typography>
              <Typography variant="body2" color="text.secondary" paragraph>
                Generate weekly summaries and monthly reports.
              </Typography>
              <Button 
                variant="contained" 
                onClick={() => navigate('/reports')}
              >
                View Reports
              </Button>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default DashboardPage;
