-- RPC function to get facture (invoice) for a user
-- Returns all active subscriptions with their associated services and total monthly cost

CREATE OR REPLACE FUNCTION get_user_factures(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(facture_data)
  INTO result
  FROM (
    SELECT
      s.id AS subscription_id,
      s.code_client,
      s.full_name,
      s.phone1,
      s.package,
      s.status AS subscription_status,
      s.created_at AS subscription_date,
      -- Base subscription price
      CASE
        WHEN s.package LIKE '%100%' THEN 1500
        WHEN s.package LIKE '%200%' THEN 2500
        WHEN s.package LIKE '%500%' THEN 4000
        ELSE 0
      END AS base_monthly_price,
      -- Active IP Publique services
      COALESCE((
        SELECT json_agg(json_build_object(
          'id', sr.id,
          'code_request', sr.code_request,
          'status', sr.status,
          'monthly_fee', sr.monthly_fee,
          'ip_address', sr.ip_address,
          'created_at', sr.created_at
        ))
        FROM service_requests sr
        WHERE sr.subscription_id = s.id
          AND sr.request_type = 'ip_publique'
          AND sr.status IN ('en_cours', 'termine')
      ), '[]'::json) AS ip_publique_services,
      -- IP Publique total fee
      COALESCE((
        SELECT SUM(sr.monthly_fee)
        FROM service_requests sr
        WHERE sr.subscription_id = s.id
          AND sr.request_type = 'ip_publique'
          AND sr.status IN ('en_cours', 'termine')
      ), 0) AS ip_publique_total,
      -- Active VoIP services
      COALESCE((
        SELECT json_agg(json_build_object(
          'id', sr.id,
          'code_request', sr.code_request,
          'status', sr.status,
          'monthly_fee', sr.monthly_fee,
          'voip_number', sr.voip_number,
          'created_at', sr.created_at
        ))
        FROM service_requests sr
        WHERE sr.subscription_id = s.id
          AND sr.request_type = 'voip'
          AND sr.status IN ('en_cours', 'termine')
      ), '[]'::json) AS voip_services,
      -- VoIP total fee
      COALESCE((
        SELECT SUM(sr.monthly_fee)
        FROM service_requests sr
        WHERE sr.subscription_id = s.id
          AND sr.request_type = 'voip'
          AND sr.status IN ('en_cours', 'termine')
      ), 0) AS voip_total,
      -- Pending modem purchases
      COALESCE((
        SELECT json_agg(json_build_object(
          'id', sr.id,
          'code_request', sr.code_request,
          'status', sr.status,
          'created_at', sr.created_at
        ))
        FROM service_requests sr
        WHERE sr.subscription_id = s.id
          AND sr.request_type = 'achat_modem'
          AND sr.status IN ('en_attente', 'en_cours')
      ), '[]'::json) AS pending_modem_requests,
      -- Pending line transfers
      COALESCE((
        SELECT json_agg(json_build_object(
          'id', sr.id,
          'code_request', sr.code_request,
          'status', sr.status,
          'new_address', sr.new_address,
          'new_gps_coordinates', sr.new_gps_coordinates,
          'created_at', sr.created_at
        ))
        FROM service_requests sr
        WHERE sr.subscription_id = s.id
          AND sr.request_type = 'transfert_ligne'
          AND sr.status IN ('en_attente', 'en_cours')
      ), '[]'::json) AS pending_transfer_requests,
      -- Pending speed changes
      COALESCE((
        SELECT json_agg(json_build_object(
          'id', scr.id,
          'code_request', scr.code_request,
          'current_package', scr.current_package,
          'new_package', scr.new_package,
          'change_type', scr.change_type,
          'current_monthly_price', scr.current_monthly_price,
          'new_monthly_price', scr.new_monthly_price,
          'penalty_fee', scr.penalty_fee,
          'status', scr.status,
          'created_at', scr.created_at
        ))
        FROM speed_change_requests scr
        WHERE scr.subscription_id = s.id
          AND scr.status IN ('en_attente', 'en_cours')
      ), '[]'::json) AS pending_speed_changes,
      -- Pending penalties (from downgrade requests)
      COALESCE((
        SELECT SUM(scr.penalty_fee)
        FROM speed_change_requests scr
        WHERE scr.subscription_id = s.id
          AND scr.change_type = 'downgrade'
          AND scr.status IN ('en_attente', 'en_cours')
      ), 0) AS pending_penalties,
      -- Calculate total monthly
      (
        CASE
          WHEN s.package LIKE '%100%' THEN 1500
          WHEN s.package LIKE '%200%' THEN 2500
          WHEN s.package LIKE '%500%' THEN 4000
          ELSE 0
        END
        + COALESCE((
          SELECT SUM(sr.monthly_fee)
          FROM service_requests sr
          WHERE sr.subscription_id = s.id
            AND sr.request_type IN ('ip_publique', 'voip')
            AND sr.status IN ('en_cours', 'termine')
        ), 0)
      ) AS total_monthly
    FROM subscriptions s
    WHERE s.user_id = p_user_id
      AND s.status IN ('active', 'equipe_en_route', 'en_cours_de_traitement')
    ORDER BY s.created_at DESC
  ) AS facture_data;

  RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_factures(UUID) TO authenticated;
