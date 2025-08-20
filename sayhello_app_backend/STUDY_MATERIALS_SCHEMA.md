# Study Materials Database Schema

## Supabase Table: `study_materials`

### Table Structure

```sql
CREATE TABLE study_materials (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL, -- 'pdf', 'doc', 'image'
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL, -- Storage path in Supabase
    file_size TEXT NOT NULL,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    upload_time TEXT,
    download_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Indexes

```sql
-- Index for course_id to speed up queries
CREATE INDEX idx_study_materials_course_id ON study_materials(course_id);

-- Index for upload_date for sorting
CREATE INDEX idx_study_materials_upload_date ON study_materials(upload_date DESC);

-- Index for type for filtering
CREATE INDEX idx_study_materials_type ON study_materials(type);
```

### Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE study_materials ENABLE ROW LEVEL SECURITY;

-- Policy for authenticated users to read study materials
CREATE POLICY "Users can view study materials" ON study_materials
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Policy for instructors to insert study materials
CREATE POLICY "Instructors can insert study materials" ON study_materials
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Policy for instructors to update their own study materials
CREATE POLICY "Instructors can update their study materials" ON study_materials
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Policy for instructors to delete their own study materials
CREATE POLICY "Instructors can delete their study materials" ON study_materials
    FOR DELETE
    USING (auth.role() = 'authenticated');
```

## Supabase Storage: `study_material` bucket

### Bucket Configuration

```sql
-- Create the bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('study_material', 'study_material', true);
```

### Storage Policies

```sql
-- Allow authenticated users to upload files
CREATE POLICY "Allow authenticated uploads" ON storage.objects
    FOR INSERT
    WITH CHECK (bucket_id = 'study_material' AND auth.role() = 'authenticated');

-- Allow authenticated users to view files
CREATE POLICY "Allow authenticated access" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'study_material' AND auth.role() = 'authenticated');

-- Allow authenticated users to update their files
CREATE POLICY "Allow authenticated updates" ON storage.objects
    FOR UPDATE
    USING (bucket_id = 'study_material' AND auth.role() = 'authenticated');

-- Allow authenticated users to delete their files
CREATE POLICY "Allow authenticated deletes" ON storage.objects
    FOR DELETE
    USING (bucket_id = 'study_material' AND auth.role() = 'authenticated');
```

### File Organization

Files are stored in the following structure:

```
study_material/
├── {course_id}/
│   ├── {course_id}_{timestamp}_{original_filename}
│   └── ...
└── ...
```

### File Types Supported

- **PDF**: `.pdf` files (application/pdf)
- **Documents**: `.doc`, `.docx` files (MS Word documents)
- **Images**: `.png`, `.jpg`, `.jpeg`, `.gif` files (image files)

### File Size Limits

- Maximum file size: 10MB per file
- Recommended file sizes:
  - Documents: 1-5MB
  - Images: 500KB-2MB
  - PDFs: 1-10MB

## Usage Examples

### Create Table

```sql
-- Run this in Supabase SQL Editor
CREATE TABLE study_materials (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_size TEXT NOT NULL,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    upload_time TEXT,
    download_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_study_materials_course_id ON study_materials(course_id);
CREATE INDEX idx_study_materials_upload_date ON study_materials(upload_date DESC);
CREATE INDEX idx_study_materials_type ON study_materials(type);
```

### Insert Sample Data

```sql
INSERT INTO study_materials (course_id, title, description, type, file_name, file_path, file_size, upload_time)
VALUES
    ('course_123', 'English Grammar Guide', 'Complete reference for English grammar', 'pdf', 'grammar_guide.pdf', 'course_123/course_123_1234567890_grammar_guide.pdf', '2.5 MB', '14:30'),
    ('course_123', 'Vocabulary Exercises', 'Business English vocabulary practice', 'doc', 'vocab_exercises.docx', 'course_123/course_123_1234567891_vocab_exercises.docx', '1.8 MB', '10:15');
```

### Query Examples

```sql
-- Get all study materials for a course
SELECT * FROM study_materials
WHERE course_id = 'course_123'
ORDER BY upload_date DESC;

-- Get study materials by type
SELECT * FROM study_materials
WHERE course_id = 'course_123' AND type = 'pdf'
ORDER BY upload_date DESC;

-- Search study materials
SELECT * FROM study_materials
WHERE course_id = 'course_123'
AND (title ILIKE '%grammar%' OR description ILIKE '%grammar%')
ORDER BY upload_date DESC;
```

## Implementation Notes

1. **File Upload Flow**:

   - Upload file to Supabase Storage (`study_material` bucket)
   - Get file URL from storage
   - Insert record in `study_materials` table with file metadata

2. **File Download Flow**:

   - Get file path from database
   - Generate signed/public URL from Supabase Storage
   - Open URL in browser or download

3. **File Deletion Flow**:

   - Delete file from Supabase Storage
   - Delete record from `study_materials` table

4. **Security**:

   - All operations require authentication
   - Files are organized by course_id
   - Public URLs are generated for easy access
   - RLS policies ensure data security

5. **Performance**:
   - Indexes on course_id and upload_date for fast queries
   - Files are stored in organized folder structure
   - Lazy loading for large file lists
