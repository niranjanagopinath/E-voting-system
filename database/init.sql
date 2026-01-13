-- E-Voting System Database Schema
-- EPIC 4: Privacy-Preserving Tallying & Result Verification

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Trustees Table
CREATE TABLE IF NOT EXISTS trustees (
    id SERIAL PRIMARY KEY,
    trustee_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    public_key TEXT,
    key_share_encrypted TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Elections Table (Basic structure for tallying context)
CREATE TABLE IF NOT EXISTS elections (
    id SERIAL PRIMARY KEY,
    election_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, active, tallying, completed
    total_voters INTEGER DEFAULT 0,
    candidates JSONB NOT NULL, -- Array of candidates with metadata
    encryption_params JSONB, -- Public key and parameters
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Encrypted Votes Table (Mock storage until EPIC 3 is implemented)
CREATE TABLE IF NOT EXISTS encrypted_votes (
    id SERIAL PRIMARY KEY,
    vote_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    election_id UUID REFERENCES elections(election_id) ON DELETE CASCADE,
    encrypted_vote TEXT NOT NULL, -- Homomorphically encrypted vote
    vote_proof TEXT, -- Zero-knowledge proof
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_tallied BOOLEAN DEFAULT FALSE,
    nonce VARCHAR(255) UNIQUE -- Replay protection
);

-- Partial Decryptions Table
CREATE TABLE IF NOT EXISTS partial_decryptions (
    id SERIAL PRIMARY KEY,
    decryption_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    election_id UUID REFERENCES elections(election_id) ON DELETE CASCADE,
    trustee_id UUID REFERENCES trustees(trustee_id) ON DELETE CASCADE,
    partial_result TEXT NOT NULL, -- Partial decryption result
    decryption_proof TEXT, -- Proof of correct decryption
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified BOOLEAN DEFAULT FALSE,
    UNIQUE(election_id, trustee_id)
);

-- Election Results Table
CREATE TABLE IF NOT EXISTS election_results (
    id SERIAL PRIMARY KEY,
    result_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    election_id UUID REFERENCES elections(election_id) ON DELETE CASCADE UNIQUE,
    final_tally JSONB NOT NULL, -- Candidate -> vote count mapping
    total_votes_tallied INTEGER NOT NULL,
    verification_hash VARCHAR(255),
    blockchain_tx_hash VARCHAR(255), -- Transaction hash when published to blockchain
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE
);

-- Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    log_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    election_id UUID REFERENCES elections(election_id) ON DELETE CASCADE,
    operation_type VARCHAR(100) NOT NULL, -- start_tally, aggregate, partial_decrypt, finalize, publish
    performed_by VARCHAR(255), -- Trustee ID or system
    details JSONB, -- Operation-specific details
    status VARCHAR(50) NOT NULL, -- success, failed, pending
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT
);

-- Verification Proofs Table
CREATE TABLE IF NOT EXISTS verification_proofs (
    id SERIAL PRIMARY KEY,
    proof_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    election_id UUID REFERENCES elections(election_id) ON DELETE CASCADE,
    proof_type VARCHAR(100) NOT NULL, -- zk_proof, decryption_proof, tally_proof
    proof_data TEXT NOT NULL,
    is_valid BOOLEAN DEFAULT NULL,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tallying Sessions Table (Track tallying process state)
CREATE TABLE IF NOT EXISTS tallying_sessions (
    id SERIAL PRIMARY KEY,
    session_id UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    election_id UUID REFERENCES elections(election_id) ON DELETE CASCADE UNIQUE,
    status VARCHAR(50) DEFAULT 'initiated', -- initiated, aggregating, decrypting, finalizing, completed, failed
    aggregated_ciphertext TEXT,
    required_trustees INTEGER NOT NULL,
    completed_trustees INTEGER DEFAULT 0,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT
);

-- Indexes for performance
CREATE INDEX idx_encrypted_votes_election ON encrypted_votes(election_id);
CREATE INDEX idx_encrypted_votes_tallied ON encrypted_votes(is_tallied);
CREATE INDEX idx_partial_decryptions_election ON partial_decryptions(election_id);
CREATE INDEX idx_partial_decryptions_trustee ON partial_decryptions(trustee_id);
CREATE INDEX idx_audit_logs_election ON audit_logs(election_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_elections_status ON elections(status);
CREATE INDEX idx_tallying_sessions_election ON tallying_sessions(election_id);

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_trustees_updated_at BEFORE UPDATE ON trustees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_elections_updated_at BEFORE UPDATE ON elections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample trustees for testing
INSERT INTO trustees (name, email, status) VALUES
    ('Trustee Alice', 'alice@evoting.com', 'active'),
    ('Trustee Bob', 'bob@evoting.com', 'active'),
    ('Trustee Charlie', 'charlie@evoting.com', 'active'),
    ('Trustee Diana', 'diana@evoting.com', 'active'),
    ('Trustee Eve', 'eve@evoting.com', 'active');

-- Insert sample election for testing
INSERT INTO elections (title, description, start_time, end_time, status, candidates) VALUES
    (
        'Presidential Election 2026',
        'National presidential election',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP + INTERVAL '7 days',
        'active',
        '[
            {"id": 1, "name": "Candidate A", "party": "Party 1"},
            {"id": 2, "name": "Candidate B", "party": "Party 2"},
            {"id": 3, "name": "Candidate C", "party": "Party 3"}
        ]'::jsonb
    );

-- Grant permissions (adjust as needed for production)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;

-- Comments for documentation
COMMENT ON TABLE trustees IS 'Stores trustee information and key shares for threshold decryption';
COMMENT ON TABLE encrypted_votes IS 'Temporary storage for encrypted votes (will be replaced by blockchain in EPIC 3)';
COMMENT ON TABLE partial_decryptions IS 'Stores partial decryption results from each trustee';
COMMENT ON TABLE election_results IS 'Final tallied and verified election results';
COMMENT ON TABLE audit_logs IS 'Immutable audit trail of all tallying operations';
COMMENT ON TABLE verification_proofs IS 'Zero-knowledge proofs for result verification';
COMMENT ON TABLE tallying_sessions IS 'Tracks the state of ongoing tallying processes';

