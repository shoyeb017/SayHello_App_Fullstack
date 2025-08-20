-- Migration: Remove unused columns from recorded_classes
-- Run this in your Supabase SQL Editor

-- 1. Remove the thumbnail column if it exists (not needed since we generate on-the-fly)
ALTER TABLE recorded_classes 
DROP COLUMN IF EXISTS recorded_thumbnail;

-- 2. Remove the old duration and size columns if they exist
ALTER TABLE recorded_classes 
DROP COLUMN IF EXISTS recorded_duration;

ALTER TABLE recorded_classes 
DROP COLUMN IF EXISTS recorded_size;

-- Verify the table structure (should only have: id, course_id, recorded_name, recorded_description, recorded_link, created_at)
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'recorded_classes' 
ORDER BY ordinal_position;
