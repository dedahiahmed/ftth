-- Add code_client column to subscriptions table
ALTER TABLE subscriptions ADD COLUMN code_client VARCHAR(20) UNIQUE;

-- Create function to generate unique code_client
CREATE OR REPLACE FUNCTION generate_code_client()
RETURNS TRIGGER AS $$
DECLARE
    new_code VARCHAR(20);
    code_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate code: FTTH + year + random 6 digits
        new_code := 'FTTH' || TO_CHAR(NOW(), 'YY') || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');

        -- Check if code already exists
        SELECT EXISTS(SELECT 1 FROM subscriptions WHERE code_client = new_code) INTO code_exists;

        -- Exit loop if code is unique
        EXIT WHEN NOT code_exists;
    END LOOP;

    NEW.code_client := new_code;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-generate code_client on insert
CREATE TRIGGER generate_code_client_trigger
    BEFORE INSERT ON subscriptions
    FOR EACH ROW
    WHEN (NEW.code_client IS NULL)
    EXECUTE FUNCTION generate_code_client();

-- Create index on code_client for faster lookups
CREATE INDEX idx_subscriptions_code_client ON subscriptions(code_client);
