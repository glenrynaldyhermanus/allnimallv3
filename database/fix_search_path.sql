-- ================================
-- Fix Supabase Search Path untuk Multi-Schema
-- Jalankan ini di Supabase SQL Editor
-- ================================

-- Set search path agar bisa akses semua schema
ALTER DATABASE postgres SET search_path = public, pet, social, pos;

-- Set search path untuk semua roles
ALTER ROLE authenticated SET search_path = public, pet, social, pos;
ALTER ROLE anon SET search_path = public, pet, social, pos;
ALTER ROLE service_role SET search_path = public, pet, social, pos;

-- ================================
-- SELESAI - Sekarang query pet.pets akan jalan
-- ================================
