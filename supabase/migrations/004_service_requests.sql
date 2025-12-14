-- Service requests table for modem purchase and line transfer
CREATE TYPE service_request_type AS ENUM ('achat_modem', 'transfert_ligne');
CREATE TYPE service_request_status AS ENUM ('en_attente', 'en_cours', 'termine', 'annule');

CREATE TABLE service_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  request_type service_request_type NOT NULL,
  status service_request_status NOT NULL DEFAULT 'en_attente',
  code_request VARCHAR(20) UNIQUE,
  notes TEXT,
  -- For transfert ligne: new location
  new_address TEXT,
  new_gps_coordinates VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Auto-generate code_request (SRV + YY + 6 digits)
CREATE OR REPLACE FUNCTION generate_service_request_code()
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
  FROM service_requests
  WHERE code_request LIKE 'SRV' || year_suffix || '%';

  new_code := 'SRV' || year_suffix || LPAD(sequence_num::TEXT, 6, '0');
  NEW.code_request := new_code;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_service_request_code
  BEFORE INSERT ON service_requests
  FOR EACH ROW
  EXECUTE FUNCTION generate_service_request_code();

-- Update timestamp trigger
CREATE TRIGGER update_service_requests_updated_at
  BEFORE UPDATE ON service_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS policies
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;

-- Users can view their own service requests
CREATE POLICY "Users can view own service requests"
  ON service_requests FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create service requests
CREATE POLICY "Users can create service requests"
  ON service_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX idx_service_requests_user_id ON service_requests(user_id);
CREATE INDEX idx_service_requests_subscription_id ON service_requests(subscription_id);
CREATE INDEX idx_service_requests_status ON service_requests(status);
