import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3001/api'
});

export const getExpenses = (params) => api.get('/expenses', { params });
export const createExpense = (data) => api.post('/expenses', data);

export const getBudgets = (params) => api.get('/budgets', { params });
export const createBudget = (data) => api.post('/budgets', data);

export const getShopping = (params) => api.get('/shopping', { params });
export const createShopping = (data) => api.post('/shopping', data);

export default api;
