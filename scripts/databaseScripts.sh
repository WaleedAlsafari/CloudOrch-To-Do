#!/usr/bin/env bash
set -euo pipefail

# Install PostgreSQL
apt-get update -y
apt-get upgrade -y
apt-get install -y postgresql

# DB + user + table (run as postgres)
sudo -u postgres psql -v ON_ERROR_STOP=1 <<'SQL'
CREATE DATABASE todoapp;
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'admin') THEN
    CREATE USER admin WITH ENCRYPTED PASSWORD 'Admin123@';
  END IF;
END$$;

GRANT ALL PRIVILEGES ON DATABASE todoapp TO admin;
SQL

# Allow backend subnet and listen on all IPs
echo "host    all    all    10.0.1.0/24    md5" >> /etc/postgresql/*/main/pg_hba.conf
sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/*/main/postgresql.conf

# Create table and grant ownership/sequence perms
sudo -u postgres psql -d todoapp -v ON_ERROR_STOP=1 <<'SQL'
CREATE TABLE IF NOT EXISTS public.todo (
  todo_id     SERIAL PRIMARY KEY,
  description TEXT        NOT NULL,
  completed   BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.todo OWNER TO admin;
GRANT ALL ON TABLE public.todo TO admin;
GRANT USAGE, SELECT ON SEQUENCE public.todo_todo_id_seq TO admin;
SQL

# Restart PostgreSQL
systemctl restart postgresql
