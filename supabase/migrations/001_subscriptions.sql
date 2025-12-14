-- Create subscription type enum
CREATE TYPE subscription_type AS ENUM ('FTTH');

-- Create subscription status enum
CREATE TYPE subscription_status AS ENUM ('en_cours_de_traitement', 'active', 'inactive');

-- Create subscriptions table
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Subscription type
    type subscription_type NOT NULL DEFAULT 'FTTH',

    -- Client information
    full_name VARCHAR(255) NOT NULL,
    phone1 VARCHAR(20) NOT NULL,
    phone2 VARCHAR(20),
    email VARCHAR(255),
    nni VARCHAR(50) NOT NULL,

    -- Identity document
    identity_type VARCHAR(100) NOT NULL,
    identity_photo_url TEXT NOT NULL,

    -- Electricity bill (optional)
    bill_type VARCHAR(50),
    bill_photo_url TEXT,

    -- Address and GPS
    address TEXT NOT NULL,
    gps_latitude DECIMAL(10, 8),
    gps_longitude DECIMAL(11, 8),

    -- Package
    package VARCHAR(100) NOT NULL,

    -- Status
    status subscription_status NOT NULL DEFAULT 'en_cours_de_traitement',

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on user_id for faster lookups
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);

-- Create index on status for filtering
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- Create index on type for filtering
CREATE INDEX idx_subscriptions_type ON subscriptions(type);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER update_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions"
    ON subscriptions
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own subscriptions
CREATE POLICY "Users can insert own subscriptions"
    ON subscriptions
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own subscriptions
CREATE POLICY "Users can update own subscriptions"
    ON subscriptions
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Create storage bucket for subscription documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('subscription-documents', 'subscription-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policy: Users can upload their own documents
CREATE POLICY "Users can upload subscription documents"
    ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'subscription-documents' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Storage policy: Users can view their own documents
CREATE POLICY "Users can view own subscription documents"
    ON storage.objects
    FOR SELECT
    USING (
        bucket_id = 'subscription-documents' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );
