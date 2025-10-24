-- ================================
-- DDL untuk menambahkan table pet.pet_timelines
-- Jalankan script ini di Supabase SQL Editor
-- ================================

-- 1. Create pet_timelines table
CREATE TABLE IF NOT EXISTS pet.pet_timelines (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  pet_id uuid NOT NULL,
  timeline_type text NOT NULL,
  title text NOT NULL,
  caption text,
  media_url text,
  media_type text,
  visibility text NOT NULL DEFAULT 'public'::text,
  event_date timestamp with time zone NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT pet_timelines_pkey PRIMARY KEY (id),
  CONSTRAINT pet_timelines_timeline_type_check CHECK (timeline_type = ANY (ARRAY['birthday'::text, 'welcome'::text, 'schedule'::text, 'activity'::text, 'media'::text, 'weight_update'::text])),
  CONSTRAINT pet_timelines_visibility_check CHECK (visibility = ANY (ARRAY['public'::text, 'private'::text])),
  CONSTRAINT pet_timelines_media_type_check CHECK (media_type IS NULL OR media_type = ANY (ARRAY['image'::text, 'video'::text]))
);

-- 2. Add foreign key constraint
ALTER TABLE pet.pet_timelines ADD CONSTRAINT pet_timelines_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id) ON DELETE CASCADE;

-- 3. Add indexes
CREATE INDEX IF NOT EXISTS idx_pet_timelines_pet_id ON pet.pet_timelines(pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_timelines_event_date ON pet.pet_timelines(event_date DESC);
CREATE INDEX IF NOT EXISTS idx_pet_timelines_timeline_type ON pet.pet_timelines(timeline_type);
CREATE INDEX IF NOT EXISTS idx_pet_timelines_visibility ON pet.pet_timelines(visibility);
CREATE INDEX IF NOT EXISTS idx_pet_timelines_pet_id_event_date ON pet.pet_timelines(pet_id, event_date DESC);

-- 4. Enable Row Level Security
ALTER TABLE pet.pet_timelines ENABLE ROW LEVEL SECURITY;

-- 5. Add RLS policies
-- Note: Using public.customers.firebase_uid instead of auth.uid() because we use Firebase Auth
-- Policy: Users can view public timelines OR their own pet's timelines
CREATE POLICY "Users can view pet timelines"
  ON pet.pet_timelines
  FOR SELECT
  USING (
    visibility = 'public' OR
    EXISTS (
      SELECT 1 FROM pet.pets
      JOIN public.customers ON customers.id = pets.owner_id
      WHERE pets.id = pet_timelines.pet_id
      AND customers.firebase_uid = (current_setting('request.jwt.claims', true)::json->>'sub')::text
    )
  );

-- Policy: Allow service role to insert (for server-side operations)
-- This allows backend to create timeline entries without user authentication
CREATE POLICY "Service role can create timelines"
  ON pet.pet_timelines
  FOR INSERT
  WITH CHECK (true);

-- Policy: Users can update their own pet's timelines
CREATE POLICY "Users can update their own pet timelines"
  ON pet.pet_timelines
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM pet.pets
      JOIN public.customers ON customers.id = pets.owner_id
      WHERE pets.id = pet_timelines.pet_id
      AND customers.firebase_uid = (current_setting('request.jwt.claims', true)::json->>'sub')::text
    )
  );

-- Policy: Users can delete their own pet's timelines
CREATE POLICY "Users can delete their own pet timelines"
  ON pet.pet_timelines
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM pet.pets
      JOIN public.customers ON customers.id = pets.owner_id
      WHERE pets.id = pet_timelines.pet_id
      AND customers.firebase_uid = (current_setting('request.jwt.claims', true)::json->>'sub')::text
    )
  );

-- 6. Add table comment
COMMENT ON TABLE pet.pet_timelines IS 'Timeline/activity feed for pets - tracks photos, schedules, weight updates, birthday, and join events';

-- ================================
-- SELESAI
-- ================================

