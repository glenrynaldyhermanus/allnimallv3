-- ================================
-- Storage Policies for pet-media bucket
-- Run this in Supabase SQL Editor
-- ================================

-- Allow anyone to upload to pet-media bucket
CREATE POLICY "Allow public uploads to pet-media"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'pet-media');

-- Allow anyone to read from pet-media bucket
CREATE POLICY "Allow public reads from pet-media"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'pet-media');

-- Allow anyone to update their uploads (optional)
CREATE POLICY "Allow public updates to pet-media"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'pet-media');

-- Allow anyone to delete their uploads (optional)
CREATE POLICY "Allow public deletes from pet-media"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'pet-media');

-- ================================
-- SELESAI
-- ================================

