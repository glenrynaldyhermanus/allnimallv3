-- ================================
-- Instagram Gallery Feature Migration
-- Adds support for photo/video gallery with social features
-- (likes, comments, shares)
-- ================================

-- 1. Update pet.pet_photos table - Add new columns
ALTER TABLE pet.pet_photos 
  ADD COLUMN IF NOT EXISTS caption TEXT,
  ADD COLUMN IF NOT EXISTS hashtags TEXT[],
  ADD COLUMN IF NOT EXISTS mime_type TEXT,
  ADD COLUMN IF NOT EXISTS file_size INTEGER,
  ADD COLUMN IF NOT EXISTS width INTEGER,
  ADD COLUMN IF NOT EXISTS height INTEGER,
  ADD COLUMN IF NOT EXISTS duration INTEGER,
  ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

-- 2. Create pet.photo_likes table
CREATE TABLE IF NOT EXISTS pet.photo_likes (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  photo_id UUID NOT NULL,
  user_id UUID,
  liked_by_ip TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT photo_likes_pkey PRIMARY KEY (id),
  CONSTRAINT photo_likes_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES pet.pet_photos(id) ON DELETE CASCADE
);

-- Add unique constraint to prevent duplicate likes
CREATE UNIQUE INDEX IF NOT EXISTS idx_photo_likes_user_unique 
  ON pet.photo_likes(photo_id, user_id) 
  WHERE user_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_photo_likes_ip_unique 
  ON pet.photo_likes(photo_id, liked_by_ip) 
  WHERE user_id IS NULL AND liked_by_ip IS NOT NULL;

-- Add index for efficient queries
CREATE INDEX IF NOT EXISTS idx_photo_likes_photo_id ON pet.photo_likes(photo_id);

-- 3. Create pet.photo_comments table
CREATE TABLE IF NOT EXISTS pet.photo_comments (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  photo_id UUID NOT NULL,
  user_id UUID,
  commenter_name TEXT,
  commenter_ip TEXT,
  comment_text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  updated_at TIMESTAMP WITH TIME ZONE,
  deleted_at TIMESTAMP WITH TIME ZONE,
  CONSTRAINT photo_comments_pkey PRIMARY KEY (id),
  CONSTRAINT photo_comments_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES pet.pet_photos(id) ON DELETE CASCADE
);

-- Add indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_photo_comments_photo_id ON pet.photo_comments(photo_id);
CREATE INDEX IF NOT EXISTS idx_photo_comments_created_at ON pet.photo_comments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_photo_comments_deleted_at ON pet.photo_comments(deleted_at);

-- 4. Create pet.photo_shares table
CREATE TABLE IF NOT EXISTS pet.photo_shares (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  photo_id UUID NOT NULL,
  shared_by_user_id UUID,
  shared_by_ip TEXT,
  shared_to_platform TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT photo_shares_pkey PRIMARY KEY (id),
  CONSTRAINT photo_shares_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES pet.pet_photos(id) ON DELETE CASCADE
);

-- Add index for efficient queries
CREATE INDEX IF NOT EXISTS idx_photo_shares_photo_id ON pet.photo_shares(photo_id);
CREATE INDEX IF NOT EXISTS idx_photo_shares_platform ON pet.photo_shares(shared_to_platform);

-- 5. Enable Row Level Security
ALTER TABLE pet.photo_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.photo_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.photo_shares ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS Policies for public access (photos are public via QR scan)

-- Photo likes policies
CREATE POLICY "Anyone can view photo likes" ON pet.photo_likes
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert photo likes" ON pet.photo_likes
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can delete their own likes" ON pet.photo_likes
  FOR DELETE USING (
    user_id = auth.uid() OR 
    (user_id IS NULL AND liked_by_ip IS NOT NULL)
  );

-- Photo comments policies
CREATE POLICY "Anyone can view non-deleted comments" ON pet.photo_comments
  FOR SELECT USING (deleted_at IS NULL);

CREATE POLICY "Anyone can insert comments" ON pet.photo_comments
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own comments" ON pet.photo_comments
  FOR UPDATE USING (
    user_id = auth.uid() OR 
    (user_id IS NULL AND commenter_ip IS NOT NULL)
  );

CREATE POLICY "Users can soft-delete their own comments" ON pet.photo_comments
  FOR UPDATE USING (
    user_id = auth.uid() OR 
    (user_id IS NULL AND commenter_ip IS NOT NULL)
  )
  WITH CHECK (deleted_at IS NOT NULL);

-- Photo shares policies (public stats only)
CREATE POLICY "Anyone can view photo shares" ON pet.photo_shares
  FOR SELECT USING (true);

CREATE POLICY "Anyone can record shares" ON pet.photo_shares
  FOR INSERT WITH CHECK (true);

-- 7. Add table comments
COMMENT ON TABLE pet.photo_likes IS 'Likes on pet photos - supports both authenticated users and anonymous via IP';
COMMENT ON TABLE pet.photo_comments IS 'Comments on pet photos - supports both authenticated users and anonymous commenters';
COMMENT ON TABLE pet.photo_shares IS 'Share tracking for pet photos to various platforms';

COMMENT ON COLUMN pet.pet_photos.caption IS 'Photo/video caption text';
COMMENT ON COLUMN pet.pet_photos.hashtags IS 'Array of hashtag strings';
COMMENT ON COLUMN pet.pet_photos.mime_type IS 'Media MIME type (e.g., image/jpeg, video/mp4)';
COMMENT ON COLUMN pet.pet_photos.duration IS 'Video duration in seconds (null for images)';
COMMENT ON COLUMN pet.pet_photos.thumbnail_url IS 'Thumbnail URL for videos';

-- ================================
-- SELESAI
-- ================================

