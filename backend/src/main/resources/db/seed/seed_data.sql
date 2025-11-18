-- Seed data for development environment
-- Run this script manually in development database

-- Insert sample users
INSERT INTO users (id, email, password_hash, full_name, role) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'john.doe@ericsson.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lbdOIGGrNG5k2jgvG', 'John Doe', 'USER'),
('550e8400-e29b-41d4-a716-446655440002', 'jane.smith@ericsson.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lbdOIGGrNG5k2jgvG', 'Jane Smith', 'ADMIN')
ON CONFLICT (email) DO NOTHING;

-- Insert sample daily entries for the past week
INSERT INTO daily_entries (user_id, entry_date, yesterday_work, today_plan, blockers) VALUES
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '6 days', 'Completed user authentication module', 'Work on daily entry CRUD operations', 'None'),
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '5 days', 'Implemented daily entry CRUD', 'Start weekly summary generation', 'Database connection issues'),
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '4 days', 'Fixed database connection', 'Complete weekly summary feature', 'None'),
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '3 days', 'Completed weekly summaries', 'Begin monthly report functionality', 'None'),
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '2 days', 'Started monthly reports', 'Finish monthly report generation', 'Complex aggregation queries'),
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE - INTERVAL '1 day', 'Completed monthly reports', 'Add export functionality', 'None'),
('550e8400-e29b-41d4-a716-446655440001', CURRENT_DATE, 'Added export features', 'Work on frontend integration', 'None')
ON CONFLICT (user_id, entry_date) DO NOTHING;

-- Insert sample weekly summary
INSERT INTO weekly_summaries (user_id, week_start, week_end, summary_text) VALUES
('550e8400-e29b-41d4-a716-446655440001', 
 CURRENT_DATE - INTERVAL '6 days', 
 CURRENT_DATE, 
 'Week Summary: Completed backend authentication, CRUD operations, and reporting features. Main blocker was database connection issues which were resolved.')
ON CONFLICT (user_id, week_start, week_end) DO NOTHING;

-- Insert sample monthly report
INSERT INTO monthly_reports (user_id, month, year, report_data) VALUES
('550e8400-e29b-41d4-a716-446655440001', 
 EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER, 
 EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
 '{"totalEntries": 7, "completedTasks": 5, "blockers": 2, "productivity": "high"}'::jsonb)
ON CONFLICT (user_id, month, year) DO NOTHING;
