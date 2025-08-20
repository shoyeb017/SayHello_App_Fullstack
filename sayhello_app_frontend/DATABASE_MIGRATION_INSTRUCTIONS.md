# Database Migration Instructions

## Problem

The app was showing this error:

```
Could not find the 'recorded_thumbnail' column of 'recorded_classes' in the schema cache
```

## New Solution: Dynamic Thumbnail Generation

Instead of storing thumbnails in the database, we now generate them **on-the-fly** from video links for better efficiency and always up-to-date thumbnails.

## Steps

### Option 1: Using Supabase Dashboard (Recommended)

1. Open your **Supabase Dashboard**
2. Go to **SQL Editor**
3. Copy the content from `migration_add_thumbnail.sql`
4. Paste it in the SQL Editor
5. Click **Run** to execute the migration

### Option 2: Using Supabase CLI (if installed)

```bash
supabase db reset
```

Or run the migration directly:

```bash
psql -h <your-db-host> -U <your-username> -d <your-database> -f migration_add_thumbnail.sql
```

## What the Migration Does

- ✅ Removes `recorded_thumbnail` column (not needed for dynamic generation)
- ✅ Removes `recorded_duration` column (old, unused)
- ✅ Removes `recorded_size` column (old, unused)
- ✅ Shows the final table structure for verification

## How Dynamic Thumbnails Work

- **YouTube** videos: Instant thumbnail extraction using video ID
- **Vimeo** videos: API-based thumbnail generation
- **Dailymotion** videos: Instant thumbnail extraction
- **Direct video files**: Graceful fallback with video icon
- **Real-time generation**: Thumbnails generated when video cards are displayed

## Benefits of Dynamic Approach

- ✅ **No storage needed**: Thumbnails aren't stored in database
- ✅ **Always current**: Thumbnails always reflect latest video state
- ✅ **Automatic updates**: If video thumbnail changes, app shows new one
- ✅ **Platform optimized**: Best quality thumbnail from each platform
- ✅ **Efficient**: No manual thumbnail upload required

## After Migration

- The app will work without database errors
- Video thumbnails will appear automatically on video cards
- No manual thumbnail upload interface
- Real-time thumbnail generation from video URLs

## Verification

After running the migration, the `recorded_classes` table should have these columns:

- `id` (UUID, Primary Key)
- `course_id` (UUID, Foreign Key)
- `recorded_name` (TEXT)
- `recorded_description` (TEXT)
- `recorded_link` (TEXT)
- `recorded_thumbnail` (TEXT) ← New column
- `created_at` (TIMESTAMP)
