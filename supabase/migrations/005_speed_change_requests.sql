-- Speed change requests table
CREATE TYPE speed_change_type AS ENUM ('upgrade', 'downgrade');

CREATE TABLE speed_change_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  code_request VARCHAR(20) UNIQUE,
  current_package VARCHAR(100) NOT NULL,
  new_package VARCHAR(100) NOT NULL,
  change_type speed_change_type NOT NULL,
  -- Pricing
  current_monthly_price INTEGER NOT NULL,
  new_monthly_price INTEGER NOT NULL,
  penalty_fee INTEGER DEFAULT 0, -- 5000 MRU for downgrade, 0 for upgrade
  -- Status
  status service_request_status NOT NULL DEFAULT 'en_attente',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Auto-generate code_request (CHG + YY + 6 digits)
CREATE OR REPLACE FUNCTION generate_speed_change_code()
RETURNS TRIGGER AS $$
DECLARE
  year_suffix VARCHAR(2);
  sequence_num INTEGER;
  new_code VARCHAR(20);
BEGIN
  year_suffix := TO_CHAR(NOW(), 'YY');

  SELECT COALESCE(MAX(
    CAST(SUBSTRING(code_request FROM 6 FOR 6) AS INTEGER)
  ), 0) + 1
  INTO sequence_num
  FROM speed_change_requests
  WHERE code_request LIKE 'CHG' || year_suffix || '%';

  new_code := 'CHG' || year_suffix || LPAD(sequence_num::TEXT, 6, '0');
  NEW.code_request := new_code;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_speed_change_code
  BEFORE INSERT ON speed_change_requests
  FOR EACH ROW
  EXECUTE FUNCTION generate_speed_change_code();

-- Update timestamp trigger
CREATE TRIGGER update_speed_change_requests_updated_at
  BEFORE UPDATE ON speed_change_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS policies
ALTER TABLE speed_change_requests ENABLE ROW LEVEL SECURITY;

-- Users can view their own speed change requests
CREATE POLICY "Users can view own speed change requests"
  ON speed_change_requests FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create speed change requests
CREATE POLICY "Users can create speed change requests"
  ON speed_change_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX idx_speed_change_requests_user_id ON speed_change_requests(user_id);
CREATE INDEX idx_speed_change_requests_subscription_id ON speed_change_requests(subscription_id);
CREATE INDEX idx_speed_change_requests_status ON speed_change_requests(status);
