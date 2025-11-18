-- Create daily_entries table
CREATE TABLE daily_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    yesterday_work TEXT,
    today_plan TEXT,
    blockers TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, entry_date)
);

-- Create indexes for performance
CREATE INDEX idx_daily_entries_user_id ON daily_entries(user_id);
CREATE INDEX idx_daily_entries_entry_date ON daily_entries(entry_date);
CREATE INDEX idx_daily_entries_user_date ON daily_entries(user_id, entry_date);
