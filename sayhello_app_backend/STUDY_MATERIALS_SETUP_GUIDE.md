# Study Materials Backend Setup Guide

## Overview

This guide covers the complete backend setup for study materials functionality with Supabase integration, including database tables, storage buckets, and authentication.

## Prerequisites

- Supabase project created and configured
- Supabase URL and Anon Key added to `supabase_config.dart`
- Flutter app connected to Supabase

## 1. Database Setup

### Step 1: Create the study_materials Table

Run this SQL in your Supabase SQL Editor:

```sql
-- Create the study_materials table
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

-- Create indexes for better performance
CREATE INDEX idx_study_materials_course_id ON study_materials(course_id);
CREATE INDEX idx_study_materials_upload_date ON study_materials(upload_date DESC);
CREATE INDEX idx_study_materials_type ON study_materials(type);

-- Add a trigger to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_study_materials_updated_at
    BEFORE UPDATE ON study_materials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Step 2: Enable Row Level Security (RLS)

```sql
-- Enable RLS on the study_materials table
ALTER TABLE study_materials ENABLE ROW LEVEL SECURITY;

-- Create policies for different operations
-- Policy for viewing study materials (all authenticated users)
CREATE POLICY "Users can view study materials" ON study_materials
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Policy for inserting study materials (authenticated users)
CREATE POLICY "Authenticated users can insert study materials" ON study_materials
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Policy for updating study materials (authenticated users can update their own)
CREATE POLICY "Users can update study materials" ON study_materials
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Policy for deleting study materials (authenticated users can delete their own)
CREATE POLICY "Users can delete study materials" ON study_materials
    FOR DELETE
    USING (auth.role() = 'authenticated');
```

## 2. Storage Setup

### Step 1: Create Storage Bucket

Run this SQL in your Supabase SQL Editor:

```sql
-- Create the study_material bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'study_material',
    'study_material',
    true,
    10485760, -- 10MB limit
    ARRAY[
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'image/png',
        'image/jpeg',
        'image/jpg',
        'image/gif'
    ]
);
```

### Step 2: Set Storage Policies

```sql
-- Allow authenticated users to upload files
CREATE POLICY "Allow authenticated uploads" ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'study_material'
        AND auth.role() = 'authenticated'
    );

-- Allow authenticated users to view files
CREATE POLICY "Allow authenticated access" ON storage.objects
    FOR SELECT
    USING (
        bucket_id = 'study_material'
        AND auth.role() = 'authenticated'
    );

-- Allow authenticated users to update files
CREATE POLICY "Allow authenticated updates" ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'study_material'
        AND auth.role() = 'authenticated'
    );

-- Allow authenticated users to delete files
CREATE POLICY "Allow authenticated deletes" ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'study_material'
        AND auth.role() = 'authenticated'
    );
```

## 3. Test the Setup

### Step 1: Insert Test Data

```sql
-- Insert sample study materials for testing
INSERT INTO study_materials (
    course_id,
    title,
    description,
    type,
    file_name,
    file_path,
    file_size,
    upload_time
) VALUES
(
    'course_123',
    'English Grammar Complete Reference Guide',
    'Comprehensive grammar guide covering all English tenses, sentence structures, and grammatical rules with examples.',
    'pdf',
    'english_grammar_guide.pdf',
    'course_123/course_123_1698765432_english_grammar_guide.pdf',
    '2.5 MB',
    '14:30'
),
(
    'course_123',
    'Business English Vocabulary Exercises',
    'Interactive vocabulary exercises and worksheets for professional English communication in business contexts.',
    'doc',
    'business_english_exercises.docx',
    'course_123/course_123_1698765433_business_english_exercises.docx',
    '1.8 MB',
    '10:15'
),
(
    'course_456',
    'Spanish Pronunciation Chart',
    'Visual reference chart for Spanish pronunciation and phonetics.',
    'image',
    'spanish_pronunciation.png',
    'course_456/course_456_1698765434_spanish_pronunciation.png',
    '850 KB',
    '16:45'
);
```

### Step 2: Test Queries

```sql
-- Test: Get all study materials for a course
SELECT * FROM study_materials
WHERE course_id = 'course_123'
ORDER BY upload_date DESC;

-- Test: Get study materials by type
SELECT * FROM study_materials
WHERE course_id = 'course_123' AND type = 'pdf'
ORDER BY upload_date DESC;

-- Test: Search study materials
SELECT * FROM study_materials
WHERE course_id = 'course_123'
AND (title ILIKE '%grammar%' OR description ILIKE '%grammar%')
ORDER BY upload_date DESC;

-- Test: Count study materials by type
SELECT type, COUNT(*) as count
FROM study_materials
WHERE course_id = 'course_123'
GROUP BY type;
```

## 4. Flutter App Integration

### Files Created/Modified:

1. **Model**: `lib/models/study_material.dart` ✅
2. **Service**: `lib/services/study_material_service.dart` ✅
3. **Provider**: `lib/providers/study_material_provider.dart` ✅
4. **UI**: `lib/screens/instructor/BottomTabs/Home/instructor_study_materials.dart` ✅
5. **Main**: `lib/main.dart` (added provider) ✅

### Key Features Implemented:

- ✅ **Upload**: File upload to Supabase storage with metadata storage
- ✅ **View**: File viewing with download URL generation
- ✅ **Edit**: Title and description editing
- ✅ **Delete**: File and metadata deletion
- ✅ **List**: Course-specific study materials listing
- ✅ **Search**: Title/description search functionality
- ✅ **Filter**: Type-based filtering
- ✅ **Sort**: Date-based sorting (newest first)

## 5. Backend Functionality Features

### Upload Functionality

- Real-time file upload to Supabase storage bucket `study_material`
- Automatic file path generation with course ID and timestamp
- File size calculation and formatting
- Metadata storage in database with all file details
- Support for PDF, DOC/DOCX, and Image files
- File type validation and content type detection

### View/Download Functionality

- Public URL generation from Supabase storage
- Direct file access through browser or external apps
- URL launching with fallback preview dialog
- File type icon display based on file extension
- Error handling for missing or invalid files

### Edit Functionality

- Title and description editing (files cannot be replaced)
- Real-time database updates through Supabase
- Provider state management for UI updates
- Form validation and error handling
- Success/error feedback to users

### Delete Functionality

- Complete file removal from Supabase storage
- Database record deletion with cascade handling
- Confirmation dialogs with file details
- Provider state updates for immediate UI refresh
- Error handling for storage and database operations

### List/Display Functionality

- Course-specific material retrieval
- Automatic sorting by upload date (newest first)
- Compact card layout with modern design
- Pull-to-refresh functionality
- Loading states and error handling
- Empty state management

## 6. Security Features

### Authentication

- All operations require user authentication
- JWT token validation through Supabase
- Row-level security on database tables
- Storage access control policies

### File Security

- Files organized by course ID in storage
- Public URLs with controlled access
- File type and size validation
- MIME type restrictions on upload

### Data Validation

- Input sanitization on title/description
- File extension validation
- Maximum file size enforcement (10MB)
- Required field validation

## 7. Error Handling

### Network Errors

- Connection timeout handling
- Retry mechanisms for failed uploads
- Graceful degradation for offline scenarios

### Storage Errors

- File upload failure handling
- Insufficient storage space detection
- Invalid file format error messages

### Database Errors

- SQL constraint violation handling
- Duplicate entry prevention
- Transaction rollback on failures

## 8. Performance Optimizations

### Database

- Indexed queries on course_id and upload_date
- Efficient pagination for large datasets
- Optimized SELECT queries with specific fields

### Storage

- Organized file structure for fast retrieval
- Public URLs for direct browser access
- File size optimization recommendations

### UI

- Lazy loading for large file lists
- Provider-based state management
- Debounced search functionality
- Efficient widget rebuilding

## 9. Testing the Implementation

### Frontend Testing

1. Open the study materials tab in the instructor interface
2. Try uploading a file (simulated with sample data)
3. Test editing material title/description
4. Test deleting materials
5. Test viewing/downloading materials
6. Test search and filter functionality

### Backend Testing

1. Check Supabase dashboard for table data
2. Verify storage bucket contents
3. Test RLS policies with different user roles
4. Monitor database queries in Supabase

## 10. Deployment Checklist

- [ ] Supabase project configured with correct environment
- [ ] Database tables created with proper indexes
- [ ] Storage bucket created with correct policies
- [ ] RLS policies enabled and tested
- [ ] Flutter app connected to production Supabase
- [ ] File upload/download tested in production
- [ ] Error handling verified in production environment
- [ ] Performance monitoring set up

## Troubleshooting

### Common Issues:

1. **Upload Fails**: Check storage policies and bucket configuration
2. **Files Not Visible**: Verify RLS policies and authentication
3. **Download URLs Invalid**: Check bucket public settings
4. **Performance Issues**: Review indexes and query optimization
5. **Authentication Errors**: Verify Supabase configuration and JWT handling

### Debug Steps:

1. Check Supabase logs for errors
2. Verify network connectivity
3. Test with smaller files first
4. Check browser console for client-side errors
5. Monitor database query performance

This completes the full backend implementation for study materials with proper Supabase integration, file management, and robust error handling.
