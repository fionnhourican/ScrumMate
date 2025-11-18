import axios from 'axios';

const API_BASE_URL = '/api/v1';

const getAuthHeaders = () => ({
  Authorization: `Bearer ${localStorage.getItem('token')}`,
});

export const summariesService = {
  async getWeeklySummaries() {
    const response = await axios.get(`${API_BASE_URL}/summaries/weekly`, {
      headers: getAuthHeaders(),
    });
    return response.data.content || response.data;
  },

  async generateWeeklySummary(weekStart: string) {
    const response = await axios.post(
      `${API_BASE_URL}/summaries/weekly/generate?weekStart=${weekStart}`,
      {},
      { headers: getAuthHeaders() }
    );
    return response.data;
  },

  async getMonthlyReports() {
    const response = await axios.get(`${API_BASE_URL}/reports/monthly`, {
      headers: getAuthHeaders(),
    });
    return response.data.content || response.data;
  },

  async generateMonthlyReport(month: number, year: number) {
    const response = await axios.post(
      `${API_BASE_URL}/reports/monthly/generate?month=${month}&year=${year}`,
      {},
      { headers: getAuthHeaders() }
    );
    return response.data;
  },
};
