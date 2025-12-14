-- Add new service request types for IP Publique and VoIP
ALTER TYPE service_request_type ADD VALUE 'ip_publique';
ALTER TYPE service_request_type ADD VALUE 'voip';

-- Add extra columns to service_requests for IP and VoIP
ALTER TABLE service_requests
  ADD COLUMN monthly_fee INTEGER DEFAULT 0,
  ADD COLUMN ip_address VARCHAR(50),
  ADD COLUMN voip_number VARCHAR(20);

-- Also add columns to subscriptions to track active services
ALTER TABLE subscriptions
  ADD COLUMN has_ip_publique BOOLEAN DEFAULT FALSE,
  ADD COLUMN ip_publique_fee INTEGER DEFAULT 0,
  ADD COLUMN has_voip BOOLEAN DEFAULT FALSE,
  ADD COLUMN voip_fee INTEGER DEFAULT 0,
  ADD COLUMN voip_number VARCHAR(20);
