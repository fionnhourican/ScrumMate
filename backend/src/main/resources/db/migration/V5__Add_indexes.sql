-- Additional performance indexes

-- Full-text search index for daily entries
CREATE INDEX idx_daily_entries_search ON daily_entries USING gin(
    to_tsvector('english', COALESCE(yesterday_work, '') || ' ' || 
                          COALESCE(today_plan, '') || ' ' || 
                          COALESCE(blockers, ''))
);

-- Composite index for date range queries
CREATE INDEX idx_daily_entries_user_date_range ON daily_entries(user_id, entry_date DESC);

-- Index for weekly summaries date range queries
CREATE INDEX idx_weekly_summaries_user_date_range ON weekly_summaries(user_id, week_start DESC);

-- Index for monthly reports ordering
CREATE INDEX idx_monthly_reports_user_year_month_desc ON monthly_reports(user_id, year DESC, month DESC);
