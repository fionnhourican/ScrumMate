import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  Typography,
  Button,
  Card,
  CardContent,
  TextField,
  Box,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Grid,
} from '@mui/material';
import { fetchEntries, createEntry, updateEntry, deleteEntry } from '../store/slices/entriesSlice';
import { RootState, AppDispatch } from '../store/store';

const DailyEntriesPage: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { entries, isLoading } = useSelector((state: RootState) => state.entries);
  const [open, setOpen] = useState(false);
  const [editingEntry, setEditingEntry] = useState<any>(null);
  const [formData, setFormData] = useState({
    entryDate: new Date().toISOString().split('T')[0],
    yesterdayWork: '',
    todayPlan: '',
    blockers: '',
  });

  useEffect(() => {
    dispatch(fetchEntries());
  }, [dispatch]);

  const handleSubmit = async () => {
    if (editingEntry) {
      await dispatch(updateEntry({ id: editingEntry.id, entry: formData }));
    } else {
      await dispatch(createEntry(formData));
    }
    setOpen(false);
    resetForm();
  };

  const handleEdit = (entry: any) => {
    setEditingEntry(entry);
    setFormData({
      entryDate: entry.entryDate,
      yesterdayWork: entry.yesterdayWork || '',
      todayPlan: entry.todayPlan || '',
      blockers: entry.blockers || '',
    });
    setOpen(true);
  };

  const handleDelete = async (id: string) => {
    if (window.confirm('Are you sure you want to delete this entry?')) {
      await dispatch(deleteEntry(id));
    }
  };

  const resetForm = () => {
    setEditingEntry(null);
    setFormData({
      entryDate: new Date().toISOString().split('T')[0],
      yesterdayWork: '',
      todayPlan: '',
      blockers: '',
    });
  };

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4">Daily Entries</Typography>
        <Button variant="contained" onClick={() => setOpen(true)}>
          Add Entry
        </Button>
      </Box>

      <Grid container spacing={2}>
        {entries.map((entry) => (
          <Grid item xs={12} key={entry.id}>
            <Card>
              <CardContent>
                <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                  <Typography variant="h6">{entry.entryDate}</Typography>
                  <Box>
                    <Button size="small" onClick={() => handleEdit(entry)}>
                      Edit
                    </Button>
                    <Button size="small" color="error" onClick={() => handleDelete(entry.id)}>
                      Delete
                    </Button>
                  </Box>
                </Box>
                <Typography variant="subtitle2" gutterBottom>Yesterday's Work:</Typography>
                <Typography variant="body2" paragraph>{entry.yesterdayWork}</Typography>
                <Typography variant="subtitle2" gutterBottom>Today's Plan:</Typography>
                <Typography variant="body2" paragraph>{entry.todayPlan}</Typography>
                <Typography variant="subtitle2" gutterBottom>Blockers:</Typography>
                <Typography variant="body2">{entry.blockers}</Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Dialog open={open} onClose={() => setOpen(false)} maxWidth="md" fullWidth>
        <DialogTitle>{editingEntry ? 'Edit Entry' : 'Add Entry'}</DialogTitle>
        <DialogContent>
          <TextField
            fullWidth
            margin="normal"
            label="Date"
            type="date"
            value={formData.entryDate}
            onChange={(e) => setFormData({ ...formData, entryDate: e.target.value })}
            InputLabelProps={{ shrink: true }}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Yesterday's Work"
            multiline
            rows={3}
            value={formData.yesterdayWork}
            onChange={(e) => setFormData({ ...formData, yesterdayWork: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Today's Plan"
            multiline
            rows={3}
            value={formData.todayPlan}
            onChange={(e) => setFormData({ ...formData, todayPlan: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Blockers"
            multiline
            rows={2}
            value={formData.blockers}
            onChange={(e) => setFormData({ ...formData, blockers: e.target.value })}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpen(false)}>Cancel</Button>
          <Button onClick={handleSubmit} variant="contained">
            {editingEntry ? 'Update' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default DailyEntriesPage;
