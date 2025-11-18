-- Database initialization script for PostgreSQL container
-- This script runs when the container starts for the first time

-- Create database if it doesn't exist
SELECT 'CREATE DATABASE scrummate'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'scrummate')\gexec

-- Create user if it doesn't exist
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'scrummate') THEN

      CREATE ROLE scrummate LOGIN PASSWORD 'password';
   END IF;
END
$do$;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE scrummate TO scrummate;

-- Connect to scrummate database
\c scrummate

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO scrummate;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO scrummate;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO scrummate;
