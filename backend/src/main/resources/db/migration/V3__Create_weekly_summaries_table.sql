-- Create weekly_summaries table
CREATE TABLE weekly_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    summary_text TEXT,
    generated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, week_start, week_end)
);

-- Create indexes for performance
CREATE INDEX idx_weekly_summaries_user_id ON weekly_summaries(user_id);
CREATE INDEX idx_weekly_summaries_week_start ON weekly_summaries(week_start);
