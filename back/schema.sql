\set db_schema 'miro_server'

CREATE SCHEMA IF NOT EXISTS :"db_schema";
SET search_path TO :"db_schema";

BEGIN;

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE whiteboards (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE whiteboard_elements (
    id BIGSERIAL PRIMARY KEY,
    whiteboard_id BIGINT NOT NULL REFERENCES whiteboards(id) ON DELETE CASCADE,
    element_type VARCHAR(50) NOT NULL CHECK (element_type IN ('text', 'shape', 'image', 'sticky')),
    content JSONB NOT NULL DEFAULT '{}',
    x FLOAT NOT NULL DEFAULT 0,
    y FLOAT NOT NULL DEFAULT 0,
    width FLOAT NOT NULL DEFAULT 100,
    height FLOAT NOT NULL DEFAULT 100,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE whiteboard_users (
    whiteboard_id BIGINT NOT NULL REFERENCES whiteboards(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (whiteboard_id, user_id)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

CREATE INDEX idx_whiteboards_title ON whiteboards(title);
CREATE INDEX idx_whiteboards_creator ON whiteboards(user_id);
CREATE INDEX idx_whiteboards_created_at ON whiteboards(created_at DESC);

CREATE INDEX idx_elements_whiteboard ON whiteboard_elements(whiteboard_id);
CREATE INDEX idx_elements_position ON whiteboard_elements USING GIST (
    box(point(x, y), point(x + width, y + height))
);

CREATE INDEX idx_whiteboard_users_user ON whiteboard_users(user_id);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_whiteboards_updated_at
BEFORE UPDATE ON whiteboards
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_elements_updated_at
BEFORE UPDATE ON whiteboard_elements
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;
