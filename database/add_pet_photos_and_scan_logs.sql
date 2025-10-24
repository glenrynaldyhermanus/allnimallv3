-- ================================
-- DDL untuk menambahkan table pet.pet_photos dan pet.pet_scan_logs
-- Jalankan script ini di Supabase SQL Editor
-- ================================

-- 1. Create pet_photos table
CREATE TABLE IF NOT EXISTS pet.pet_photos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_id uuid NOT NULL,
  photo_url text NOT NULL,
  is_primary boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  CONSTRAINT pet_photos_pkey PRIMARY KEY (id)
);

-- 2. Create pet_scan_logs table
CREATE TABLE IF NOT EXISTS pet.pet_scan_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  pet_id uuid NOT NULL,
  latitude numeric,
  longitude numeric,
  scanned_by_ip text,
  user_agent text,
  device_info jsonb DEFAULT '{}'::jsonb,
  location_accuracy numeric,
  location_name text,
  CONSTRAINT pet_scan_logs_pkey PRIMARY KEY (id)
);

-- 3. Add foreign key constraints
ALTER TABLE pet.pet_photos ADD CONSTRAINT pet_photos_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_scan_logs ADD CONSTRAINT pet_scan_logs_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);

-- 4. Add indexes
CREATE INDEX IF NOT EXISTS idx_pet_photos_pet_id ON pet.pet_photos(pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_photos_is_primary ON pet.pet_photos(is_primary);
CREATE INDEX IF NOT EXISTS idx_pet_photos_deleted_at ON pet.pet_photos(deleted_at);
CREATE INDEX IF NOT EXISTS idx_pet_scan_logs_pet_id ON pet.pet_scan_logs(pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_scan_logs_created_at ON pet.pet_scan_logs(created_at);

-- 5. Enable Row Level Security
ALTER TABLE pet.pet_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_scan_logs ENABLE ROW LEVEL SECURITY;

-- 6. Add table comments
COMMENT ON TABLE pet.pet_photos IS 'Photo gallery for pets - supports multiple photos with primary selection';
COMMENT ON TABLE pet.pet_scan_logs IS 'QR code scan history tracking for pet location and safety';

-- ================================
-- SELESAI
-- ================================

