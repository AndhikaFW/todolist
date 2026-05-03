CREATE DATABASE tutam_todos;

\c tutam_todos;

CREATE TABLE todos (
    id          SERIAL          PRIMARY KEY,
    title       VARCHAR(255)    NOT NULL,
    description TEXT,
    completed   BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_todos_created_at ON todos (created_at DESC);
