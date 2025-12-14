-- Factures System: Tables and Triggers for payment tracking

-- Facture types enum
CREATE TYPE facture_type AS ENUM (
  'installation',      -- Frais installation 1000 MRU
  'transfert_ligne',   -- Transfert ligne 420 MRU
  'achat_modem',       -- Achat modem 1000 MRU
  'mensuel'            -- Monthly invoice (subscription + services)
);

-- Facture status enum
CREATE TYPE facture_status AS ENUM (
  'en_attente',    -- Waiting for payment
  'payee',         -- Paid
  'annulee'        -- Cancelled
);

-- Main factures table
CREATE TABLE factures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  code_facture VARCHAR(30) UNIQUE,
  facture_type facture_type NOT NULL,

  -- Amounts
  montant_base INTEGER NOT NULL DEFAULT 0,           -- Base amount (subscription/service fee)
  montant_ip_publique INTEGER NOT NULL DEFAULT 0,    -- IP Publique monthly
  montant_voip INTEGER NOT NULL DEFAULT 0,           -- VoIP monthly
  montant_autres INTEGER NOT NULL DEFAULT 0,         -- Other charges
  montant_total INTEGER NOT NULL DEFAULT 0,          -- Total amount

  -- Status
  status facture_status NOT NULL DEFAULT 'en_attente',

  -- Dates
  date_emission TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  date_echeance TIMESTAMP WITH TIME ZONE,            -- Due date
  date_paiement TIMESTAMP WITH TIME ZONE,            -- Payment date

  -- Period for monthly invoices (from 23rd to 22nd)
  periode_debut DATE,
  periode_fin DATE,

  -- Reference to what triggered this facture
  reference_type VARCHAR(50),  -- 'subscription', 'service_request', 'speed_change'
  reference_id UUID,

  -- Details JSON for line items
  details JSONB DEFAULT '[]'::jsonb,

  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Auto-generate code_facture (FAC + YY + MM + 6 digits)
CREATE OR REPLACE FUNCTION generate_facture_code()
RETURNS TRIGGER AS $$
DECLARE
  year_month VARCHAR(4);
  sequence_num INTEGER;
  new_code VARCHAR(30);
BEGIN
  year_month := TO_CHAR(NOW(), 'YYMM');

  SELECT COALESCE(MAX(
    CAST(SUBSTRING(code_facture FROM 8 FOR 6) AS INTEGER)
  ), 0) + 1
  INTO sequence_num
  FROM factures
  WHERE code_facture LIKE 'FAC' || year_month || '%';

  new_code := 'FAC' || year_month || LPAD(sequence_num::TEXT, 6, '0');
  NEW.code_facture := new_code;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_facture_code
  BEFORE INSERT ON factures
  FOR EACH ROW
  EXECUTE FUNCTION generate_facture_code();

-- Update timestamp trigger for factures
CREATE TRIGGER update_factures_updated_at
  BEFORE UPDATE ON factures
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- TRIGGER: Installation fee (1000 MRU)
-- When subscription status changes from en_cours_de_traitement to equipe_en_route
-- This means the user has ALREADY PAID, so status = 'payee'
-- ============================================
CREATE OR REPLACE FUNCTION create_installation_facture()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status = 'en_cours_de_traitement' AND NEW.status = 'equipe_en_route' THEN
    INSERT INTO factures (
      user_id,
      subscription_id,
      facture_type,
      montant_base,
      montant_total,
      status,
      date_echeance,
      date_paiement,
      reference_type,
      reference_id,
      details
    ) VALUES (
      NEW.user_id,
      NEW.id,
      'installation',
      1000,
      1000,
      'payee',  -- Already paid since moving to equipe_en_route
      NOW(),
      NOW(),    -- Payment date is now
      'subscription',
      NEW.id,
      jsonb_build_array(
        jsonb_build_object(
          'description', 'Frais d''installation FTTH',
          'quantite', 1,
          'prix_unitaire', 1000,
          'total', 1000
        )
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_installation_facture
  AFTER UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION create_installation_facture();

-- ============================================
-- TRIGGER: Transfert ligne fee (420 MRU)
-- When service_request (transfert_ligne) status changes from en_attente to en_cours
-- This means the user has ALREADY PAID, so status = 'payee'
-- ============================================
CREATE OR REPLACE FUNCTION create_transfert_facture()
RETURNS TRIGGER AS $$
DECLARE
  sub_record RECORD;
BEGIN
  IF NEW.request_type = 'transfert_ligne'
     AND OLD.status = 'en_attente'
     AND NEW.status = 'en_cours' THEN

    SELECT * INTO sub_record FROM subscriptions WHERE id = NEW.subscription_id;

    INSERT INTO factures (
      user_id,
      subscription_id,
      facture_type,
      montant_base,
      montant_total,
      status,
      date_echeance,
      date_paiement,
      reference_type,
      reference_id,
      details
    ) VALUES (
      NEW.user_id,
      NEW.subscription_id,
      'transfert_ligne',
      420,
      420,
      'payee',  -- Already paid since moving to en_cours
      NOW(),
      NOW(),    -- Payment date is now
      'service_request',
      NEW.id,
      jsonb_build_array(
        jsonb_build_object(
          'description', 'Frais de transfert de ligne',
          'code_request', NEW.code_request,
          'nouvelle_adresse', NEW.new_address,
          'quantite', 1,
          'prix_unitaire', 420,
          'total', 420
        )
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_transfert_facture
  AFTER UPDATE ON service_requests
  FOR EACH ROW
  EXECUTE FUNCTION create_transfert_facture();

-- ============================================
-- TRIGGER: Achat modem fee (1000 MRU)
-- When service_request (achat_modem) status changes from en_attente to en_cours
-- This means the user has ALREADY PAID, so status = 'payee'
-- ============================================
CREATE OR REPLACE FUNCTION create_modem_facture()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.request_type = 'achat_modem'
     AND OLD.status = 'en_attente'
     AND NEW.status = 'en_cours' THEN

    INSERT INTO factures (
      user_id,
      subscription_id,
      facture_type,
      montant_base,
      montant_total,
      status,
      date_echeance,
      date_paiement,
      reference_type,
      reference_id,
      details
    ) VALUES (
      NEW.user_id,
      NEW.subscription_id,
      'achat_modem',
      1000,
      1000,
      'payee',  -- Already paid since moving to en_cours
      NOW(),
      NOW(),    -- Payment date is now
      'service_request',
      NEW.id,
      jsonb_build_array(
        jsonb_build_object(
          'description', 'Achat modem FTTH',
          'code_request', NEW.code_request,
          'quantite', 1,
          'prix_unitaire', 1000,
          'total', 1000
        )
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_modem_facture
  AFTER UPDATE ON service_requests
  FOR EACH ROW
  EXECUTE FUNCTION create_modem_facture();

-- ============================================
-- FUNCTION: Generate monthly factures (called on 23rd of each month)
-- This should be called by a cron job or scheduled function
-- ============================================
CREATE OR REPLACE FUNCTION generate_monthly_factures()
RETURNS INTEGER AS $$
DECLARE
  sub RECORD;
  ip_services RECORD;
  voip_services RECORD;
  base_price INTEGER;
  ip_total INTEGER;
  voip_total INTEGER;
  total_amount INTEGER;
  details_json JSONB;
  period_start DATE;
  period_end DATE;
  facture_count INTEGER := 0;
BEGIN
  -- Period: 23rd of current month to 22nd of next month
  period_start := DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '22 days';
  period_end := period_start + INTERVAL '1 month' - INTERVAL '1 day';

  -- Loop through all active subscriptions
  FOR sub IN
    SELECT s.*, u.id as user_uuid
    FROM subscriptions s
    JOIN auth.users u ON s.user_id = u.id
    WHERE s.status = 'active'
  LOOP
    -- Calculate base price based on package
    base_price := CASE
      WHEN sub.package LIKE '%100%' THEN 1500
      WHEN sub.package LIKE '%200%' THEN 2500
      WHEN sub.package LIKE '%500%' THEN 4000
      ELSE 0
    END;

    -- Calculate IP Publique total
    SELECT COALESCE(SUM(monthly_fee), 0) INTO ip_total
    FROM service_requests
    WHERE subscription_id = sub.id
      AND request_type = 'ip_publique'
      AND status = 'termine';

    -- Calculate VoIP total
    SELECT COALESCE(SUM(monthly_fee), 0) INTO voip_total
    FROM service_requests
    WHERE subscription_id = sub.id
      AND request_type = 'voip'
      AND status = 'termine';

    total_amount := base_price + ip_total + voip_total;

    -- Build details JSON
    details_json := jsonb_build_array(
      jsonb_build_object(
        'description', 'Abonnement FTTH ' || sub.package,
        'quantite', 1,
        'prix_unitaire', base_price,
        'total', base_price
      )
    );

    -- Add IP Publique details if any
    IF ip_total > 0 THEN
      FOR ip_services IN
        SELECT * FROM service_requests
        WHERE subscription_id = sub.id
          AND request_type = 'ip_publique'
          AND status = 'termine'
      LOOP
        details_json := details_json || jsonb_build_array(
          jsonb_build_object(
            'description', 'IP Publique - ' || COALESCE(ip_services.ip_address, 'En cours'),
            'quantite', 1,
            'prix_unitaire', ip_services.monthly_fee,
            'total', ip_services.monthly_fee
          )
        );
      END LOOP;
    END IF;

    -- Add VoIP details if any
    IF voip_total > 0 THEN
      FOR voip_services IN
        SELECT * FROM service_requests
        WHERE subscription_id = sub.id
          AND request_type = 'voip'
          AND status = 'termine'
      LOOP
        details_json := details_json || jsonb_build_array(
          jsonb_build_object(
            'description', 'Service VoIP - ' || COALESCE(voip_services.voip_number, 'En cours'),
            'quantite', 1,
            'prix_unitaire', voip_services.monthly_fee,
            'total', voip_services.monthly_fee
          )
        );
      END LOOP;
    END IF;

    -- Insert monthly facture
    INSERT INTO factures (
      user_id,
      subscription_id,
      facture_type,
      montant_base,
      montant_ip_publique,
      montant_voip,
      montant_total,
      date_echeance,
      periode_debut,
      periode_fin,
      reference_type,
      reference_id,
      details
    ) VALUES (
      sub.user_id,
      sub.id,
      'mensuel',
      base_price,
      ip_total,
      voip_total,
      total_amount,
      period_end,
      period_start,
      period_end,
      'subscription',
      sub.id,
      details_json
    );

    facture_count := facture_count + 1;
  END LOOP;

  RETURN facture_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- RPC: Get all factures for a user
-- ============================================
CREATE OR REPLACE FUNCTION get_user_factures_v2(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(facture_data ORDER BY created_at DESC)
  INTO result
  FROM (
    SELECT
      f.id,
      f.code_facture,
      f.facture_type,
      f.montant_base,
      f.montant_ip_publique,
      f.montant_voip,
      f.montant_autres,
      f.montant_total,
      f.status,
      f.date_emission,
      f.date_echeance,
      f.date_paiement,
      f.periode_debut,
      f.periode_fin,
      f.details,
      f.created_at,
      s.code_client,
      s.full_name,
      s.phone1,
      s.package,
      s.status as subscription_status
    FROM factures f
    JOIN subscriptions s ON f.subscription_id = s.id
    WHERE f.user_id = p_user_id
  ) AS facture_data;

  RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- RPC: Get pending (unpaid) factures for a user
-- ============================================
CREATE OR REPLACE FUNCTION get_pending_factures(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(facture_data ORDER BY date_echeance ASC)
  INTO result
  FROM (
    SELECT
      f.id,
      f.code_facture,
      f.facture_type,
      f.montant_total,
      f.status,
      f.date_emission,
      f.date_echeance,
      f.periode_debut,
      f.periode_fin,
      f.details,
      s.code_client,
      s.full_name,
      s.package
    FROM factures f
    JOIN subscriptions s ON f.subscription_id = s.id
    WHERE f.user_id = p_user_id
      AND f.status = 'en_attente'
  ) AS facture_data;

  RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- RPC: Get current monthly facture (from 23rd)
-- Only returns monthly factures that are pending and within current billing period
-- ============================================
CREATE OR REPLACE FUNCTION get_current_monthly_factures(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
  current_period_start DATE;
BEGIN
  -- Calculate current billing period start (23rd of current or previous month)
  IF EXTRACT(DAY FROM CURRENT_DATE) >= 23 THEN
    current_period_start := DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '22 days';
  ELSE
    current_period_start := DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month' + INTERVAL '22 days';
  END IF;

  SELECT json_agg(facture_data ORDER BY created_at DESC)
  INTO result
  FROM (
    SELECT
      f.id,
      f.code_facture,
      f.facture_type,
      f.montant_base,
      f.montant_ip_publique,
      f.montant_voip,
      f.montant_total,
      f.status,
      f.date_emission,
      f.date_echeance,
      f.periode_debut,
      f.periode_fin,
      f.details,
      s.code_client,
      s.full_name,
      s.phone1,
      s.package
    FROM factures f
    JOIN subscriptions s ON f.subscription_id = s.id
    WHERE f.user_id = p_user_id
      AND f.facture_type = 'mensuel'
      AND f.status = 'en_attente'
      AND f.periode_debut >= current_period_start
  ) AS facture_data;

  RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- RPC: Mark facture as paid
-- ============================================
CREATE OR REPLACE FUNCTION mark_facture_paid(p_facture_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE factures
  SET status = 'payee',
      date_paiement = NOW()
  WHERE id = p_facture_id
    AND user_id = p_user_id
    AND status = 'en_attente';

  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS policies for factures
ALTER TABLE factures ENABLE ROW LEVEL SECURITY;

-- Users can view their own factures
CREATE POLICY "Users can view own factures"
  ON factures FOR SELECT
  USING (auth.uid() = user_id);

-- Only system can insert factures (via triggers)
CREATE POLICY "System can insert factures"
  ON factures FOR INSERT
  WITH CHECK (true);

-- Users can update their own factures (for payment marking)
CREATE POLICY "Users can update own factures"
  ON factures FOR UPDATE
  USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX idx_factures_user_id ON factures(user_id);
CREATE INDEX idx_factures_subscription_id ON factures(subscription_id);
CREATE INDEX idx_factures_status ON factures(status);
CREATE INDEX idx_factures_type ON factures(facture_type);
CREATE INDEX idx_factures_date_emission ON factures(date_emission);
CREATE INDEX idx_factures_periode ON factures(periode_debut, periode_fin);

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_user_factures_v2(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_factures(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_monthly_factures(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION mark_facture_paid(UUID, UUID) TO authenticated;
