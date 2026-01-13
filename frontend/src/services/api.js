/**
 * API Service for E-Voting System
 * Handles all HTTP requests to the backend
 */

import axios from 'axios';

// Use relative URL to leverage proxy configuration
const API_BASE_URL = '/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 60000, // 60 second timeout for long operations like vote encryption
});

// Request interceptor for logging
api.interceptors.request.use(
  (config) => {
    console.log(`API Request: ${config.method?.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

// Trustees API
export const trusteesAPI = {
  getAll: () => api.get('/trustees'),
  getById: (id) => api.get(`/trustees/${id}`),
  register: (data) => api.post('/trustees/register', data),
  generateKeyShare: (trusteeId) => api.post(`/trustees/${trusteeId}/key-share`),
  getThresholdInfo: () => api.get('/trustees/threshold/info'),
};

// Tallying API
export const tallyingAPI = {
  start: (electionId) => api.post('/tally/start', { election_id: electionId }),
  partialDecrypt: (trusteeId, electionId) =>
    api.post(`/tally/partial-decrypt/${trusteeId}?election_id=${electionId}`),
  finalize: (electionId) => api.post('/tally/finalize', { election_id: electionId }),
  getStatus: (electionId) => api.get(`/tally/status/${electionId}`),
  getAggregationInfo: (electionId) => api.get(`/tally/aggregate-info/${electionId}`),
};

// Results API
export const resultsAPI = {
  getAll: () => api.get('/results'),
  getByElectionId: (electionId) => api.get(`/results/${electionId}`),
  verify: (electionId) => api.post('/results/verify', { election_id: electionId }),
  getAuditLog: (electionId) => api.get(`/results/audit-log/${electionId}`),
  publishToBlockchain: (electionId) => api.post(`/results/publish/${electionId}`),
  getSummary: (electionId) => api.get(`/results/summary/${electionId}`),
};

// Mock Data API
export const mockDataAPI = {
  generateVotes: (count, electionId) =>
    api.post(`/mock/generate-votes?count=${count}${electionId ? `&election_id=${electionId}` : ''}`),
  resetDatabase: () => api.post('/mock/reset-database?confirm=true'),
  getElectionStats: (electionId) =>
    api.get(`/mock/election-stats${electionId ? `?election_id=${electionId}` : ''}`),
  setupTrustees: () => api.post('/mock/setup-trustees'),
};

// Health Check
export const healthCheck = () => api.get('/health', { baseURL: '' });

export default api;
