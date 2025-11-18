-- Create monthly_reports table
CREATE TABLE monthly_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
    year INTEGER NOT NULL CHECK (year >= 2020),
    report_data JSONB,
    generated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, month, year)
);

-- Create indexes for performance
CREATE INDEX idx_monthly_reports_user_id ON monthly_reports(user_id);
CREATE INDEX idx_monthly_reports_year_month ON monthly_reports(year, month);
