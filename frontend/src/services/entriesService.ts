import axios from 'axios';

const API_BASE_URL = '/api/v1';

const getAuthHeaders = () => ({
  Authorization: `Bearer ${localStorage.getItem('token')}`,
});

export const entriesService = {
  async getEntries() {
    const response = await axios.get(`${API_BASE_URL}/entries`, {
      headers: getAuthHeaders(),
    });
    return response.data.content || response.data;
  },

  async createEntry(entry: any) {
    const response = await axios.post(`${API_BASE_URL}/entries`, entry, {
      headers: getAuthHeaders(),
    });
    return response.data;
  },

  async updateEntry(id: string, entry: any) {
    const response = await axios.put(`${API_BASE_URL}/entries/${id}`, entry, {
      headers: getAuthHeaders(),
    });
    return response.data;
  },

  async deleteEntry(id: string) {
    await axios.delete(`${API_BASE_URL}/entries/${id}`, {
      headers: getAuthHeaders(),
    });
  },
};
