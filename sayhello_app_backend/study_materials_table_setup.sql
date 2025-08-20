-- Study Materials Table Creation/Update Script for Supabase
-- Run this in your Supabase SQL Editor

-- First, check if the table exists and create/update it
CREATE TABLE IF NOT EXISTS study_materials (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id TEXT NOT NULL,
    material_title TEXT NOT NULL,
    material_description TEXT,
    material_type TEXT NOT NULL,
    material_link TEXT NOT NULL,
    file_name TEXT,
    file_path TEXT,
    file_size TEXT,
    upload_time TEXT,
    download_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_study_materials_course_id ON study_materials(course_id);
CREATE INDEX IF NOT EXISTS idx_study_materials_created_at ON study_materials(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_study_materials_type ON study_materials(material_type);

-- Enable Row Level Security
ALTER TABLE study_materials ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view study materials" ON study_materials;
DROP POLICY IF EXISTS "Authenticated users can insert study materials" ON study_materials;
DROP POLICY IF EXISTS "Users can update study materials" ON study_materials;
DROP POLICY IF EXISTS "Users can delete study materials" ON study_materials;

-- Create RLS policies
CREATE POLICY "Users can view study materials" ON study_materials
    FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert study materials" ON study_materials
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update study materials" ON study_materials
    FOR UPDATE
    USING (auth.role() = 'authenticated');

CREATE POLICY "Users can delete study materials" ON study_materials
    FOR DELETE
    USING (auth.role() = 'authenticated');

-- Create or update the storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('study_material', 'study_material', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
INSERT INTO storage.policies (bucket_id, policy_name, definition)
VALUES 
    ('study_material', 'Allow authenticated uploads', '{"role": "authenticated"}')
ON CONFLICT (bucket_id, policy_name) DO NOTHING;

-- Test query to verify table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'study_materials'
ORDER BY ordinal_position;

-- Insert sample data for testing (optional)
INSERT INTO study_materials (
    course_id, 
    material_title, 
    material_description, 
    material_type, 
    material_link,
    file_name,
    file_path,
    file_size,
    upload_time
) VALUES 
(
    'course_123', 
    'Sample PDF Document', 
    'This is a sample PDF document for testing', 
    'pdf', 
    'course_123/sample_document.pdf',
    'sample_document.pdf',
    'course_123/sample_document.pdf',
    '1.2 MB',
    '14:30'
) ON CONFLICT DO NOTHING;

-- Verify the data
SELECT * FROM study_materials LIMIT 5;
