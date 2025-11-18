// Copyright (c) 2025 Telefonaktiebolaget LM Ericsson
// ScrumMate K6 Load Testing Scenarios

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const apiResponseTime = new Trend('api_response_time');

// Test configuration
export const options = {
  stages: [
    { duration: '2m', target: 10 },   // Ramp up
    { duration: '5m', target: 50 },   // Stay at 50 users
    { duration: '2m', target: 100 },  // Ramp to 100 users
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.01'],   // Error rate under 1%
    errors: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://scrummate-backend.scrummate-dev:8080';

// Test data
const users = [
  { email: 'user1@test.com', password: 'password123' },
  { email: 'user2@test.com', password: 'password123' },
  { email: 'user3@test.com', password: 'password123' },
];

// Authentication helper
function authenticate() {
  const user = users[Math.floor(Math.random() * users.length)];
  const loginResponse = http.post(`${BASE_URL}/api/v1/auth/login`, {
    email: user.email,
    password: user.password,
  }, {
    headers: { 'Content-Type': 'application/json' },
  });

  check(loginResponse, {
    'login successful': (r) => r.status === 200,
    'token received': (r) => r.json('token') !== undefined,
  });

  return loginResponse.json('token');
}

// Main test scenario
export default function () {
  const token = authenticate();
  
  if (!token) {
    errorRate.add(1);
    return;
  }

  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  // Test 1: Get daily entries
  const entriesResponse = http.get(`${BASE_URL}/api/v1/entries`, { headers });
  check(entriesResponse, {
    'entries retrieved': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });
  apiResponseTime.add(entriesResponse.timings.duration);

  sleep(1);

  // Test 2: Create daily entry
  const entryData = {
    entryDate: new Date().toISOString().split('T')[0],
    yesterdayWork: 'Completed user authentication module',
    todayPlan: 'Work on daily entry CRUD operations',
    blockers: 'None',
  };

  const createResponse = http.post(`${BASE_URL}/api/v1/entries`, JSON.stringify(entryData), { headers });
  check(createResponse, {
    'entry created': (r) => r.status === 201,
    'create response time < 300ms': (r) => r.timings.duration < 300,
  });
  apiResponseTime.add(createResponse.timings.duration);

  sleep(1);

  // Test 3: Generate weekly summary
  const summaryResponse = http.post(`${BASE_URL}/api/v1/summaries/weekly/generate`, {}, { headers });
  check(summaryResponse, {
    'summary generated': (r) => r.status === 200 || r.status === 201,
    'summary response time < 1000ms': (r) => r.timings.duration < 1000,
  });
  apiResponseTime.add(summaryResponse.timings.duration);

  sleep(2);

  // Test 4: Get monthly report
  const reportResponse = http.get(`${BASE_URL}/api/v1/reports/monthly`, { headers });
  check(reportResponse, {
    'report retrieved': (r) => r.status === 200,
    'report response time < 500ms': (r) => r.timings.duration < 500,
  });
  apiResponseTime.add(reportResponse.timings.duration);

  // Record errors
  if (entriesResponse.status >= 400 || createResponse.status >= 400 || 
      summaryResponse.status >= 400 || reportResponse.status >= 400) {
    errorRate.add(1);
  } else {
    errorRate.add(0);
  }

  sleep(1);
}

// Smoke test scenario
export function smokeTest() {
  const response = http.get(`${BASE_URL}/actuator/health`);
  check(response, {
    'health check passed': (r) => r.status === 200,
    'response time < 100ms': (r) => r.timings.duration < 100,
  });
}

// Stress test scenario
export function stressTest() {
  const token = authenticate();
  
  if (!token) return;

  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  // Rapid fire requests
  for (let i = 0; i < 10; i++) {
    const response = http.get(`${BASE_URL}/api/v1/entries`, { headers });
    check(response, {
      'stress test request successful': (r) => r.status === 200,
    });
    
    if (response.status >= 400) {
      errorRate.add(1);
    }
  }
}
