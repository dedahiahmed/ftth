-- Add team visit and feedback columns to subscriptions table
ALTER TABLE subscriptions
ADD COLUMN team_notified_at TIMESTAMPTZ,
ADD COLUMN team_arrived_at TIMESTAMPTZ,
ADD COLUMN installation_completed_at TIMESTAMPTZ,
ADD COLUMN team_not_arrived_reported_at TIMESTAMPTZ,
ADD COLUMN service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
ADD COLUMN service_feedback TEXT,
ADD COLUMN feedback_submitted_at TIMESTAMPTZ;

-- Create team visit reports table for "team not arrived" reports
CREATE TABLE team_visit_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    report_type VARCHAR(50) NOT NULL, -- 'team_not_arrived', 'team_arrived', 'installation_done'
    message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on subscription_id
CREATE INDEX idx_team_visit_reports_subscription_id ON team_visit_reports(subscription_id);

-- Enable RLS on team_visit_reports
ALTER TABLE team_visit_reports ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own reports
CREATE POLICY "Users can view own team visit reports"
    ON team_visit_reports
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own reports
CREATE POLICY "Users can insert own team visit reports"
    ON team_visit_reports
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Create service_feedbacks table for detailed feedback
CREATE TABLE service_feedbacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Rating categories (1-5)
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    team_professionalism INTEGER CHECK (team_professionalism >= 1 AND team_professionalism <= 5),
    installation_quality INTEGER CHECK (installation_quality >= 1 AND installation_quality <= 5),
    response_time INTEGER CHECK (response_time >= 1 AND response_time <= 5),

    -- Text feedback
    comments TEXT,
    would_recommend BOOLEAN,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index
CREATE INDEX idx_service_feedbacks_subscription_id ON service_feedbacks(subscription_id);

-- Enable RLS
ALTER TABLE service_feedbacks ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own feedbacks
CREATE POLICY "Users can view own service feedbacks"
    ON service_feedbacks
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own feedbacks
CREATE POLICY "Users can insert own service feedbacks"
    ON service_feedbacks
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Function to update subscription when feedback is submitted
CREATE OR REPLACE FUNCTION update_subscription_on_feedback()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE subscriptions
    SET
        service_rating = NEW.overall_rating,
        service_feedback = NEW.comments,
        feedback_submitted_at = NOW()
    WHERE id = NEW.subscription_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update subscription on feedback insert
CREATE TRIGGER update_subscription_feedback
    AFTER INSERT ON service_feedbacks
    FOR EACH ROW
    EXECUTE FUNCTION update_subscription_on_feedback();
