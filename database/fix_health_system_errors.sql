-- Fix Health System Errors
-- Run this manually in Supabase SQL Editor

-- 1. CLEAN UP DUPLICATE PET_HEALTHS
-- Keep only the most recent record for each pet_id
WITH ranked_healths AS (
  SELECT 
    id,
    pet_id,
    ROW_NUMBER() OVER (PARTITION BY pet_id ORDER BY updated_at DESC NULLS LAST, created_at DESC) as rn
  FROM pet.pet_healths
)
DELETE FROM pet.pet_healths
WHERE id IN (
  SELECT id FROM ranked_healths WHERE rn > 1
);

-- Add unique constraint on pet_id to prevent future duplicates
ALTER TABLE pet.pet_healths 
ADD CONSTRAINT pet_healths_pet_id_unique 
UNIQUE (pet_id);

-- 2. FIX RLS POLICY FOR PET_HEALTH_HISTORY
-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view health history of their pets" ON pet.pet_health_history;
DROP POLICY IF EXISTS "Users can create health history for their pets" ON pet.pet_health_history;
DROP POLICY IF EXISTS "System can create health history" ON pet.pet_health_history;

-- Enable RLS
ALTER TABLE pet.pet_health_history ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view health history of their own pets
CREATE POLICY "Users can view health history of their pets"
ON pet.pet_health_history
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM pet.pets
    WHERE pets.id = pet_health_history.pet_id
    AND pets.owner_id = auth.uid()
  )
);

-- Policy: Authenticated users can create health history for their own pets
CREATE POLICY "Users can create health history for their pets"
ON pet.pet_health_history
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM pet.pets
    WHERE pets.id = pet_health_history.pet_id
    AND pets.owner_id = auth.uid()
  )
);

-- Policy: Allow all authenticated users to create (for now - adjust based on your needs)
-- This is more permissive if you want to allow updates from system
CREATE POLICY "Authenticated users can create health history"
ON pet.pet_health_history
FOR INSERT
TO authenticated
WITH CHECK (true);

-- 3. ADD 'health_update' TO TIMELINE TYPE CONSTRAINT
-- Drop the existing constraint
ALTER TABLE pet.pet_timelines DROP CONSTRAINT IF EXISTS pet_timelines_timeline_type_check;

-- Add new constraint with 'health_update' included
ALTER TABLE pet.pet_timelines 
ADD CONSTRAINT pet_timelines_timeline_type_check 
CHECK (timeline_type IN (
  'birthday', 
  'welcome', 
  'schedule', 
  'activity', 
  'media', 
  'weight_update',
  'health_update'  -- Added for new health system
));

-- 4. VERIFY FIXES
-- Check for any remaining duplicates
SELECT pet_id, COUNT(*) as count
FROM pet.pet_healths
GROUP BY pet_id
HAVING COUNT(*) > 1;

-- Should return no rows if duplicates are cleaned up

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'pet_health_history';

-- Check timeline constraint
SELECT conname, contype, pg_get_constraintdef(oid) as definition
FROM pg_constraint 
WHERE conname = 'pet_timelines_timeline_type_check';

