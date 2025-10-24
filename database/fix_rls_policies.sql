-- Fix RLS Policies for pet_health_history
-- Run this manually in Supabase SQL Editor

-- Clean up conflicting RLS policies for pet_health_history
DROP POLICY IF EXISTS "Allow users to insert health history for their own pets" ON pet.pet_health_history;
DROP POLICY IF EXISTS "Allow users to read their own pet health history" ON pet.pet_health_history;
DROP POLICY IF EXISTS "Authenticated users can create health history" ON pet.pet_health_history;
DROP POLICY IF EXISTS "Users can create health history for their pets" ON pet.pet_health_history;
DROP POLICY IF EXISTS "Users can view health history of their pets" ON pet.pet_health_history;

-- Create clean, simple RLS policies
-- Policy: Users can view health history of their own pets
CREATE POLICY "Users can view health history of their pets"
ON pet.pet_health_history
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM pet.pets 
    WHERE pets.id = pet_health_history.pet_id 
    AND pets.owner_id = auth.uid()
  )
);

-- Policy: Users can create health history for their own pets
CREATE POLICY "Users can create health history for their own pets"
ON pet.pet_health_history
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM pet.pets 
    WHERE pets.id = pet_health_history.pet_id 
    AND pets.owner_id = auth.uid()
  )
);

-- Policy: Users can update health history for their own pets
CREATE POLICY "Users can update health history for their own pets"
ON pet.pet_health_history
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM pet.pets 
    WHERE pets.id = pet_health_history.pet_id 
    AND pets.owner_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM pet.pets 
    WHERE pets.id = pet_health_history.pet_id 
    AND pets.owner_id = auth.uid()
  )
);

-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'pet_health_history'
ORDER BY policyname;
