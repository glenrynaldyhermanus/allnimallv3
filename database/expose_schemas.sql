-- ================================
-- Expose schemas untuk Supabase API
-- Jalankan ini di Supabase SQL Editor
-- ================================

-- Grant usage pada semua schema
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA pet TO authenticated;
GRANT USAGE ON SCHEMA social TO authenticated;
GRANT USAGE ON SCHEMA pos TO authenticated;

-- Grant usage untuk anon role juga
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA pet TO anon;
GRANT USAGE ON SCHEMA social TO anon;
GRANT USAGE ON SCHEMA pos TO anon;

-- Set search path
ALTER DATABASE postgres SET search_path = public, pet, social, pos;

-- ================================
-- SELESAI
-- ================================
