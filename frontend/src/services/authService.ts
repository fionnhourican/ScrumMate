import axios from 'axios';

const API_BASE_URL = '/api/v1';

interface AuthResponse {
  token: string;
  email: string;
  fullName: string;
}

export const authService = {
  async login(email: string, password: string): Promise<AuthResponse> {
    const response = await axios.post(`${API_BASE_URL}/auth/login`, {
      email,
      password,
    });
    return response.data;
  },

  async register(email: string, password: string, fullName: string): Promise<AuthResponse> {
    const response = await axios.post(`${API_BASE_URL}/auth/register`, {
      email,
      password,
      fullName,
    });
    return response.data;
  },
};
