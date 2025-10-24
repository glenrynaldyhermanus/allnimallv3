-- Migration: Rename notes column to story in pet.pets table
-- Date: 2025-10-23
-- Description: Change notes column to story to better reflect the content (full pet story)

-- Rename the column
ALTER TABLE pet.pets RENAME COLUMN notes TO story;

-- Update comment
COMMENT ON COLUMN pet.pets.story IS 'The full story about the pet (generated from onboarding, excluding the first sentence)';

