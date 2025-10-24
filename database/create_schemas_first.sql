-- ================================
-- STEP 1: Buat schemas dulu sebelum table
-- Jalankan ini PERTAMA di Supabase SQL Editor
-- ================================

-- Buat schema jika belum ada
CREATE SCHEMA IF NOT EXISTS pet;
CREATE SCHEMA IF NOT EXISTS social;
CREATE SCHEMA IF NOT EXISTS pos;

-- Set permissions untuk schema
GRANT USAGE ON SCHEMA pet TO authenticated;
GRANT USAGE ON SCHEMA social TO authenticated;
GRANT USAGE ON SCHEMA pos TO authenticated;

-- Enable RLS pada schema
ALTER SCHEMA pet SET row_security = on;
ALTER SCHEMA social SET row_security = on;
ALTER SCHEMA pos SET row_security = on;

-- ================================
-- SELESAI - Schema sudah dibuat
-- ================================
